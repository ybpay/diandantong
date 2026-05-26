module Ddt
  class Shift < Ddt::Base
    include BelongsToBranchWithTouch
    belongs_to :account, class_name: "Ddt::Account"

    has_many :shift_items, class_name: "Ddt::ShiftItem", dependent: :destroy
    has_many :base_shift_items, ->{ base }, class_name: "Ddt::ShiftItem"
    has_many :recharge_shift_items, ->{ recharge }, class_name: "Ddt::ShiftItem"
    acts_as_paranoid

    get_with_shop_time_zone :created_at, :closed_at
    after_create :open

    scope :opening, ->{where(state: 'opening')}
    scope :closed, ->{where(state: 'closed')}
    acts_as_type :state, [:opening, :closed]
    delegate :name, to: :account, prefix: true, allow_nil: true

    def open
      order_quantity = OrderService::Api::Statistic.order_quantity(query: { branch_id_eq: branch_id }, group_by: :state)
      self.update(
        pending_orders_before:   (order_quantity[:pending] || 0),
        confirmed_orders_before: (order_quantity[:confirmed] || 0),
        completed_orders_before: (order_quantity[:completed] || 0)
      )
      Ddt::Notification::Event::Shift::Opened.create_and_send_notification(
          branch: branch,
          shift_id: self.id
      )
      sdu_setting = branch.sale_data_uploader_setting
      if sdu_setting.enable? && sdu_setting.auto_upload_after_shift?
        ::Ddt::SaleDataUploaderSetting.delay_for(10.seconds).upload_orders(branch_id, 1.minute.ago, 1.minute.since)
      end
    end

    def shift_closed_at
      closed_at
    end

    def close
      transaction do
        self.update_amount
        self.update(state: 'closed', closed_at: Time.now)
      end
      CompleteOrderAfterShiftCloseWorker.perform_in(1.second, self.id)
      Ddt::Notification::Event::Shift::Closed.create_and_send_notification(
          branch: branch,
          shift_id: self.id
      )
      sdu_setting = branch.sale_data_uploader_setting
      if sdu_setting.enable? && sdu_setting.auto_upload_after_shift?
        ::Ddt::SaleDataUploaderSetting.delay_for(10.seconds).upload_orders(branch_id, self.created_at.ago(10.seconds), 10.seconds.since)
      end
    end

    def update_amount
      order_quantity = OrderService::Api::Statistic.order_quantity(query: { branch_id_eq: branch_id }, group_by: :state)
      self.pending_orders_after   = (order_quantity[:pending] || 0)
      self.confirmed_orders_after = (order_quantity[:confirmed] || 0)
      self.completed_orders_after = (order_quantity[:completed] || 0)
      summary = BranchSummary.new(branch, start_at: self.created_at, end_at: (self.closed_at || Time.now))
      fake_shift = Shift.create_fake_shift(summary)
      transaction do
        self.base_shift_items.delete_all
        self.recharge_shift_items.delete_all
        fake_base_shift_items = fake_shift.delete_field(:base_shift_items)
        fake_recharge_shift_items = fake_shift.delete_field(:recharge_shift_items)
        fake_shift.each_pair do |name, value|
          self.send("#{name}=", value)
        end
        fake_base_shift_items.each do |fake_shift_item|
          self.base_shift_items.create!(fake_shift_item.to_h)
        end
        fake_recharge_shift_items.each do |fake_recharge_shift_item|
          self.recharge_shift_items.create!(fake_recharge_shift_item.to_h)
        end
        self.save
      end
    end

    def self.create_fake_shift(summary)
      shift = OpenStruct.new
      shift.base_shift_items = []
      shift.recharge_shift_items = []
      summary.pay_item_amounts.each do |item|
        amount = item[:amount]
        attrs = item.slice(:pay_method_id, :amount, :actual_amount, :pay_method_name, :pay_method_code, :count)
        attrs[:not_actual_amount] = attrs[:amount] - attrs[:actual_amount]
        if item[:pay_method_name_sym].try(:to_sym) == :vip_card_pay
          attrs[:cash_amount] = item[:cash_amount]
          attrs[:extra_amount]= item[:extra_amount]
        end
        shift.base_shift_items << OpenStruct.new(attrs)
      end
      summary.recharge_pay_item_amounts.each do |item|
        amount = item[:amount]
        attrs = item.slice(:pay_method_id, :amount, :actual_amount, :pay_method_name, :pay_method_code, :count)
        attrs[:not_actual_amount] = attrs[:amount] - attrs[:actual_amount]
        shift.recharge_shift_items << OpenStruct.new(attrs)
      end
      shift.total_amount                  = summary.total_amount
      shift.total_actual_amount           = summary.actual_amount
      shift.unpaid_amount                 = summary.unpaid_amount
      shift.total_customter_count         = summary.customter_count
      shift.total_eat_in_hall_order_count = summary.eat_in_hall_order_count

      shift.order_from_wechat_count   = summary.track_from_quantities[:FromWechat]   || 0
      shift.order_from_webpos_count   = summary.track_from_quantities[:FromWebpos]   || 0
      shift.order_from_app_count      = summary.track_from_quantities[:FromApp]      || 0
      shift.order_from_webstore_count = 0 # webstore 已下线
      shift.order_from_unknow_count   = summary.track_from_quantities[:FromUnknow]   || 0

      shift.recharge_amount                   = summary.recharge_amount
      shift.recharge_extra_amount             = summary.recharge_extra_amount
      shift.vip_card_pay_amount               = summary.vip_card_pay_amount
      shift.recharge_order_count              = summary.recharge_order_count

      shift.exchange_amount                   = summary.exchange_amount
      shift.discount_amount                   = summary.discount_amount
      shift.moling_amount                     = summary.moling_amount
      total_eat_in_hall_order_amount          = summary.eat_in_hall_order_amount
      shift.per_capita_consumption            = shift.total_customter_count > 0 ? (total_eat_in_hall_order_amount / shift.total_customter_count).round(2) : 0
      shift.per_eat_in_hall_order_consumption = shift.total_eat_in_hall_order_count > 0 ? (total_eat_in_hall_order_amount / shift.total_eat_in_hall_order_count).round(2) : 0
      shift.subtract_item_count               = summary.subtract_item_count
      shift.total_subtract_item_amount        = summary.subtract_item_amount
      shift
    end

    def paid_orders
      branch.orders.where(paid_at: time_interval)
    end

    def print_text
      text = BillTemplate::Shift::Bill.new(self).render
      text.gsub(" ", "&ensp;").gsub("\n", "<br/>")
    end

    def recharge_print_text
      text = BillTemplate::Shift::RechargeBill.new(self).render
      text.gsub(" ", "&ensp;").gsub("\n", "<br/>")
    end

    def select_json
      { id: id, name: "#{self.created_at.strftime('%F %T')}--#{self.closed_at.strftime('%F %T')}" }
    end

    def time_label
      "#{self.created_at.strftime('%F %T')}--#{self.closed_at.strftime('%F %T')}"
    end

    private
    def time_interval
      is_closed? ?  self.created_at..self.closed_at : self.created_at..Time.now
    end
  end
end
