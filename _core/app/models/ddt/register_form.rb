module Ddt
  class RegisterForm < Ddt::Base
  	attr_accessor :password
    auto_strip_attributes :login_id, :email, :phone, :delete_whitespaces => true
    validates :phone, presence: true, length: 3..20, on: :create
    validate :validate_uniq_of_phone, on: :create
    validates :login_id, presence: true, login_id: true, on: :update
    validates_presence_of   :email, on: :update
    # validates_uniqueness_of :email, :allow_blank => true, on: :update
    validates_format_of     :email, :with  => Devise.email_regexp, :allow_blank => true, :if => :email_changed?, on: :update
    validate :validate_uniq_of_email_or_login_id, on: :update
    scope :failed, ->{where(shop_id: nil)}

    validates_presence_of     :password, on: :update
    validates_confirmation_of :password, on: :update
    validates_length_of       :password, :within => Devise.password_length, :allow_blank => true, on: :update
    acts_as_type :track_from, %W(FromBackend FromMobile FromWechat), %W(网页后台 手机浏览器 微信)

    default_scope -> {order("created_at DESC")}

    

    scope :inexpired, -> {where("created_at > ? ", 2.hours.ago)}

    after_create :set_access_token
    after_create :check_failed_register_form

    def check_failed_register_form
      Ddt::CheckRegisterCompleteWorker.perform_in(30.minutes, self.id)
    end


    def set_access_token
      self.update_attribute(:access_token, SecureRandom.urlsafe_base64)
    end

    def validate_uniq_of_phone
      if Ddt::Account.find_by(phone: self.phone, built_in: true).present?
        self.errors.add(:phone, "手机号已经被注册")
      end

      unless self.accept_term?
        self.errors.add(:accept_term, "必须接受用户许可协议才能允许进入下一步")
      end
    end

    def validate_uniq_of_email_or_login_id
      account = Ddt::Account.find_by("built_in = 1 and (login_id = ? or email = ?)", self.login_id, self.email)
      if account.present? && account.email == self.email
        self.errors.add(:email, "邮箱已经被注册为主帐号，不允许重复使用")
      elsif account.present? && account.login_id == self.login_id
        self.errors.add(:login_id, "用户名已经被注册，不允许重复使用")
      end
    end
  end
end