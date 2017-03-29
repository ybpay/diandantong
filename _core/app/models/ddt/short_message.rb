# encoding: utf-8
module Ddt
  class ShortMessage < Ddt::Base
    replicated_model

    belongs_to :branch, class_name: "Ddt::Branch"
    belongs_to :shop, class_name: "Ddt::Shop"
    has_one :sms_captcha, class_name: 'Ddt::SmsCaptcha', autosave: true

    acts_as_type :sms_type, [:order, :validation_code, :queue, :custom, :captcha, :birthday, :card_wallet_change], %W[订单短信 验证码短信 排号短信 自定义短信 注册验证码 生日短信 会员卡余额变动短信]

    ### validations
    #validates :shop, presence: true
    #validates :branch, presence: true
    belongs_to :owner, polymorphic: true
    validates :to, presence: true, length: 3..20
    # validates :template, presence: true
    # validates :parameters, presence: true
    validates :size, presence: true
    validates :sms_captcha, presence: true, if: 'is_validation_code? or is_captcha?'

    validate :shop_use_short_message, on: :create
    validate :short_message_count, on: :create

    ### callbacks
    before_validation :generate_content, if: 'is_validation_code? or is_captcha?'
    before_validation :update_body_size
    after_create :decrement_count
    after_create :send_short_message

    
    def self.build_validation_short_message(shop, user, to, sms_captcha)
      shop.short_messages.build({
        to: to,
        owner: user,
        sms_type: :validation_code,
        sms_captcha: sms_captcha
      })
    end

    def self.wrap_short_message_to_send(shop, to, sms_type, body)
      shop.short_messages.build({
        to: to,
        shop: shop,
        sms_type: sms_type,
        body: body
      })
    end

    def self.wrap_custom_message_to_send(shop, to, body)
      self.wrap_short_message_to_send(shop, to, :custom, body)
    end

    def self.wrap_birthday_message_to_send(shop, to, body)
      body = "生日快乐， #{body}"
      self.wrap_short_message_to_send(shop, to, :birthday, body)
    end

    def body_brief
      if body && body.size > 20
        body[0...20] + "..."
      else
        body
      end
    end

    private

    def update_body_size
      self.size = (self.body.length / 65.0).ceil
    end

    def shop_use_short_message
      if shop.present? && !shop.short_message_setting.use_sms?
        errors.add(:base, "shop does not use short messages")
      end
    end

    def short_message_count
      if shop.present? && shop.short_message_setting.remaining_count < self.size
        errors.add(:base, I18n.t("can't be greater than shop remaining"))
      end
    end

    def send_short_message
      result, info = Ddt::SmsProvider::Cl2009.send(to, body)
      if result
        self.message_number = info
        true
      else
        self.errors[:base] << info
        raise info
      end
    end

    def decrement_count
      if shop.present?
        setting = shop.short_message_setting
        setting.with_lock do
          setting.increment!(:used_count, self.size)
        end
      end
    end

    def generate_content
      return false unless self.sms_captcha.present?
      self.sms_captcha.generate_code
      case self.sms_type
      when :captcha
        self.body = "欢迎注册点单通，您的验证码为#{self.sms_captcha.code}，30分钟内有效。"
      when :validation_code
        self.body = "欢迎使用#{shop.try(:name)}会员卡，您的验证码为#{self.sms_captcha.code}，30分钟内有效。"
      else
        raise "unknow msg_type #{self.sms_type} of ShortMessage"
      end
    end


  end
end
