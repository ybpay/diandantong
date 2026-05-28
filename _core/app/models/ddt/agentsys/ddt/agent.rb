# encoding: utf-8
module Ddt
  class Agent < Ddt::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:email]

    include Discard::Model
    default_scope { kept }
    auto_strip_attributes :domain
    ### relationships
    has_many :agent_rels
    has_many :agent_printers
    has_many :agent_zones, through: :agent_rels
    has_many :lisences
    has_many :shop_recharge_records, class_name: 'Ddt::ShopRechargeRecord'
    has_many :agent_logs, dependent: :destroy
    belongs_to :sale_employee, class_name: 'Ddt::SaleEmployee'
    belongs_to :user, class_name: 'Ddt::User'
    after_save :record_updated_sale_employee_at

    acts_as_type :agent_type, [:first_level, :second_level, :third_level, :normal_level, :hardware_level], %W[一级代理商 二级代理商 三级代理商 分销商 硬件渠道商]

    delegate :user_open_id, to: :user, allow_nil: true

    ### validations
    validates_presence_of :agent_no, :name, :phone
    validates :discount, presence: true, numericality: {greater_than_or_equal_to: 0, less_than_or_equal: 1}
    validates_uniqueness_of :agent_no

    validates :balance, presence:true, numericality: { greater_than_or_equal_to: 0}


    ### uploader
    include Ddt::CarrierWaveBridge
    mount_uploader :logo, AgentLogoUploader
    mount_uploader :rect_logo, AgentRectLogoUploader

    ### callbacks
    before_validation :set_plocy_version
    after_save :record_balance_delta, if: :balance_changed?
    after_destroy :release_agent_rels

    default_scope { order("created_at DESC") }
    scope :of_oem, -> {where(:is_oem => true)}

    accepts_nested_attributes_for :agent_rels

    HARDWARE = 0.8
    NORMAL = 0.35
    THIRD  = 0.35
    SECOND = 0.25
    FIRST  = 0.15
    

    

    def self.default_discounts
      {
        hardware_level: HARDWARE,
        normal_level: NORMAL,
        third_level:  THIRD,
        second_level: SECOND,
        first_level:  FIRST
      }
    end
    
    def new_record_printer_code_price
      first_level_price = (Ddt::Shop::DEFAULT_PRINTER_CODE_PRICE * FIRST).round(0)
      second_level_price = (Ddt::Shop::DEFAULT_PRINTER_CODE_PRICE * SECOND).round(0)
      third_level_price = (Ddt::Shop::DEFAULT_PRINTER_CODE_PRICE * THIRD).round(0)
      normal_level_price = (Ddt::Shop::DEFAULT_PRINTER_CODE_PRICE * NORMAL).round(0)
      hardware_level_price = (Ddt::Shop::DEFAULT_PRINTER_CODE_PRICE * HARDWARE).round(0)
      return {
        first_level: first_level_price,
        second_level: second_level_price,
        third_level: third_level_price,
        normal_level: normal_level_price,
        hardware_level: hardware_level_price
      }
    end

    def shops
      if self.exclusive?
        sql = ""
        self.agent_zones.each do |zone|
          sql += "OR city_code like '#{self.city_code_format(zone)}' "
        end
        # sql = "is_suspicious=0 and (agent_no = ? #{sql})"
        sql = "agent_no = ? #{sql}"
        Shop.where(sql, self.agent_no)
      else
        Shop.where(agent_no: self.agent_no)
      end
    end

    def city_code_format(agent_zone)
      return nil if !self.exclusive?
      city_code = agent_zone.city_code
      if city_code[4,2] == "00"
        city_code[4,2]= "__"
      end

      if city_code[2,2] == "00"
        city_code[2,2] = "__"
      end
      city_code
    end

    def support_brand_name
      return self.brand if self.is_oem? && self.brand.present?
      Ddt::SiteConfig.brand_name
    end

    def support_brand_link
      self.wechat_introduce_url
    end

    def support_company_name
      return self.company_name if self.is_oem? && self.company_name.present?
      Ddt::SiteConfig.company_name
    end

    def is_oem_name
      self.is_oem? ? 'OEM厂商' : '点单通代理'
    end

    def price(lisence)
      
        group_price= 0
        lisence.feature_module_group.split(",").each do |group_module| 
          prices = Ddt::FeatureModuleGroup.prices_hash
          related_to_branch_num = Ddt::FeatureModuleGroup.related_to_branch_num
          if(related_to_branch_num[group_module])
            group_price += (prices[group_module] * lisence.branch_num * self.discount)        
          else
            group_price += (prices[group_module] * self.discount)          
          end
        end
        group_price 
      
    end

    def clear_balance
      if self.balance > 0
        transaction do
          self.agent_logs.create!(log_type: :expiration, balance_delta: -self.balance, description: "账号过期，余额清零")
          self.update_column(:balance, 0)
        end
      end
    end

    def expiration_time
      self.agent_rels.map(&:agent_to).max
    end

    def select_json
      { id: self.id, name: self.name }
    end

    def plocy_version_hint
      case self.plocy_version
      when /VERSION_1/ then '该代理开通期间使用的代理商政策为版本一（历史版本）, 请谨慎修改'
      else
      end
    end

    def db_printer_code_price
      100  * self.discount
    end

    def purchase_printer_code(count)
      transaction do
        price = self.db_printer_code_price * count
        self.agent_logs.create!(log_type: :purchase_printer_code, balance_delta: -price, description: "购买打印机授权码 #{count}个")
        self.decrement!(:balance, price)
        result = Ddt::Printer::Api.send_post("/printers/create_normal", { count: count, name: "[代理商]#{self.name}" })
        result.each do |p|
          self.agent_printers.create(printer_code: p[:printer_code], secret: p[:secret], token: p[:token], discount_price: self.db_printer_code_price)
        end
      end
    end

    def domain_url
      if domain.present?
        domain.start_with?('http://') ?  domain : "http://#{domain}"
      else
        nil
      end
    end

    private

    def set_plocy_version
      self.plocy_version = "VERSION_3" if self.plocy_version.blank?
    end

    def release_agent_rels
      agent_rels.each{|rel| rel.release}
    end


    def record_balance_delta
      delta = self.balance - self.balance_was
      self.agent_logs.create!(log_type: :recharge, balance_delta: delta, description: "管理员充值")
    end

    def record_updated_sale_employee_at
      touch(:updated_sale_employee_at) if self.sale_employee_id_changed?
    end



  end
end
