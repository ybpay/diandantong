# encoding:utf-8
module Ddt
  class Printer < Base
    include Ddt::BelongsToBranch
    auto_strip_attributes :number, :api_key, :member_code, :phone, :token
    acts_as_type :type, ['Ddt::Printer::Feiyin', 'Ddt::Printer::Feie', 'Ddt::Printer::Normal', 'Ddt::Printer::Fengchi'], %W[飞印打印机 点单通云打印机黑色款 普通打印机 点单通云打印机灰白款]
    acts_as_type :use_scene, ['webpos', 'kitchen', 'queue', 'label', 'guest'], %W[收银台 厨房 排号 标签打印 客看单]
    acts_as_type :print_spec, ['58', '80'], %W[58mm 80mm]
    validates_presence_of :use_scene

    has_many :print_records, class_name: 'Ddt::PrintRecord', dependent: :delete_all
    has_and_belongs_to_many :products, :join_table => 'ddt_printers_products', class_name: 'Ddt::Product'
    has_and_belongs_to_many :ban_products, :join_table => 'ddt_printers_ban_products', class_name: 'Ddt::Product'
    has_and_belongs_to_many :categories, :join_table => 'ddt_printers_categories', class_name: 'Ddt::Category'
    has_and_belongs_to_many :tables, :join_table => 'ddt_printers_tables', class_name: 'Ddt::Table'
    has_one :target, dependent: :destroy, class_name: 'Ddt::Target', as: :targetable

    ids_string_for :products, :categories, :tables, :ban_products

    scope :by_type, ->(type){ where(type: type) if type.present? }
    scope :enable, ->{ where(enable: true)}
    scope :active, ->{ enable }
    scope :use_in, ->(*scenes){where(use_scene: scenes)}
    scope :use_in_label, ->{where(use_scene: :label)}
    scope :use_in_webpos, ->{where(use_scene: :webpos)}
    scope :use_in_kitchen,->{where(use_scene: :kitchen)}
    scope :use_in_queue, ->{where(use_scene: :queue)}
    scope :use_in_guest, ->{where(use_scene: :guest)}

    validates_presence_of :number, :name, :type
    validates_numericality_of :times, :greater_than => 0, :less_than => 10
    validate :printer_code_in_binded_printer_codes, on: :create

    def print_order(order)
      print(order.order_detail_in_bill(printer: self))
    end

    def print(contents, times = 1, uuid:)
      raise "print should be implemented by sub-class (#{self.class}, id: #{self.id})"
    end

    def test_print
      self.print('打印测试') rescue false
    end

    def is_print_all_label
      return is_print_all? ? "全品打印机" : "非全品打印机"
    end

    def concern_table(order)
      return true if self.table_ids.blank?
      return false if order.table_id.blank?
      self.table_ids.include? order.table_id
    end

    def concern_line_item(line_items)
      return true if self.is_print_all?
      return false if white_list_product_ids.empty?
      line_items.any? {|line_item| line_item.in_white_list?(white_list_product_ids)}
    end

    def white_list_product_ids
      return @white_list_product_ids if @white_list_product_ids.present?
      pids = self.categories.product_ids_with_sub
      @white_list_product_ids = [self.product_ids, pids].flatten.uniq - self.ban_product_ids
    end
    alias_method :white_list_ids, :white_list_product_ids

    [:feiyin, :feie, :normal, :fengchi].each do |type_name|
      define_method "is_#{type_name}?" do
        self.type_sym == type_name
      end
    end

    def type_sym
      self.class.name.demodulize.underscore.to_sym
    end

    def self.load_print_manager_config
      YAML.load_file("#{Rails.root}/config/print_manager.yml")[Rails.env]
    end

    def select_json
      { id: id, name: "#{name}-#{number}"}
    end

    def notify_error(print_state, print_state_reason)
      if self.branch.present?
        Ddt::Notification::Event::Printer::NotifyError.create_and_send_notification(
            # sync: true, # 调试的时候可以打开这个选项加快开发速度, 但 websocket-rails 与 thin 在同一进程会崩溃
            branch_id: self.branch_id,
            printer_id: self.id,
            print_state: print_state,
            print_state_reason: print_state_reason
        )
      end
    end

    def notify_not_working(last_print_success_at)
      # 通过直接找 Printer，可能存在 branch_id 对应的门店不存在
      if self.branch.present?
        Ddt::Notification::Event::Printer::NotifyNotWorking.create_and_send_notification(
            # sync: true, # 调试的时候可以打开这个选项加快开发速度, 但 websocket-rails 与 thin 在同一进程会崩溃
            branch_id: self.branch_id,
            printer_id: self.id,
            last_print_success_at: last_print_success_at
        )
      end
    end

    def backend_show_path
      "/backend/shops/#{self.shop.slug}/branches/#{self.branch_id}/printers"
    end

    def self.get_states(branch)
      printers = branch.printers.active
      if printers.present?
        states = Ddt::Printer::Api.send_get("/printers/get_states", {
            printers: printers.map do |it|
              {
                  printer_type: it.type_sym,
                  printer_code: it.number,
                  token: it.token
              }
            end
        })
        result = []
        printers.each_with_index do |printer, index|
          state = states[index]
          result << {
              id: printer.id,
              name: printer.name,
              type: printer.type_sym,
              number: printer.number,
              state: state[:state],
              state_name: state[:state_name],
              print_state: state[:print_state],
              print_state_name: state[:print_state_name],
              print_state_reason: state[:print_state_reason],
              new_print_record_count: state[:new_print_record_count],
              last_print_success_at: state[:last_print_success_at]
          }
        end
        result
      else
        []
      end
    end

    def printer_code_in_binded_printer_codes
      if self.is_normal? && self.shop.printer_codes.where(:code => self.number).blank?
        self.errors.add(:number, "授权码必须要是已申请的授权码")
      end
    end

  end
end
