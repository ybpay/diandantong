# encoding:utf-8
module Ddt
  class PayMethod < Ddt::Base
    acts_as_paranoid

    include ListScope
    include Ddt::BelongsToShopWithTouch
    has_many :pay_items, class_name: "Ddt::PayItem"
    has_many :shift_items, class_name: "Ddt::ShiftItem"
    scope :builtin, ->{ where(builtin: true)}
    scope :online, ->{ where(name_sym: [:alipay, :wechatpay, :baidupay])}
    scope :platform, ->{ where(name_sym: [:alipay, :wechatpay, :baidupay, :alipay_offline, :wechatpay_offline])}
    scope :enable, ->{ where(enable: true)}
    scope :actual, ->{ where('percent_of_actual > 0')}
    scope :appendable, ->{
      where("name_sym NOT IN ('vip_card_pay', 'alipay', 'wechatpay', 'baidupay', 'alipay_offline', 'wechatpay_offline') OR name_sym IS NULL")
    }
    validates :name, presence: true , uniqueness: { scope: [:deleted_at, :shop_id]}
    validates :code, uniqueness: { scope: [:deleted_at, :shop_id]}, allow_blank: true
    validates :percent_of_actual, numericality: {integer: true, greater_than: -1, less_than: 101}
    acts_as_list scope: [:shop_id, :deleted_at]
    default_scope ->{list_order}


    before_save :reset_name_abbr, if: :name_changed?
    validate :check_builtin, if: :builtin?
    # code

    def self.builtin_names
      [:pay_on_face, :pay_on_receive, :pay_on_arrive, :alipay, :wechatpay, :baidupay, :vip_card_pay, :bank_card_pay, :alipay_offline, :wechatpay_offline, :tick_for_account]
    end

    def cannot_change_enable_negative?
      [:alipay, :wechatpay, :baidupay, :vip_card_pay, :alipay_offline, :wechatpay_offline].include?(self.name_sym.try(:to_sym))
    end

    self.builtin_names.each do |pay_method|
      define_method "#{pay_method}?" do
        pay_method.to_s == self.name_sym
      end
    end

    def vip_card_pay?
      self.name_sym.try(:to_sym) == :vip_card_pay
    end

    def online?
      [:alipay, :wechatpay, :baidupay].include? self.name_sym.try(:to_sym)
    end

    # 支付平台
    def pay_platform?
      [:alipay, :wechatpay, :baidupay, :alipay_offline, :wechatpay_offline].include? self.name_sym.try(:to_sym)
    end

    def not_pay_platform?
      !pay_platform?
    end

    def reset_name_abbr
      self.name_abbr = PinYin.abbr(self.name)
    end

    def get_payment_method
      case self.name_sym.try(:to_sym)
        when :alipay, :alipay_offline
          self.shop.current_alipay_method
        when :wechatpay, :wechatpay_offline
          self.shop.current_wechatpay_method
        when :baidupay
          self.shop.current_baidupay_method
      end
    end

    def select_json
      { id: self.id, name: self.name }
    end

    def percent
      ((1.0 * self.percent_of_actual)/100)
    end

    private
    def check_builtin
      self.errors[:name] << "不能修改" if !self.new_record? && self.name_changed?
    end
  end
end
