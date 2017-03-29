#encoding: utf-8
# Schema Information
# Table name: base_users
# email:                        string
# encrypted_password:           string
# reset_password_token:         string
# reset_password_sent_at:       datetime
# remember_created_at:          datetime
# sign_in_count:                integer
# current_sign_in_at:           datetime
# last_sign_in_at:              datetime
# current_sign_in_ip:           string
# last_sign_in_ip:              string
# confirmation_token:           string
# confirmed_at:                 datetime
# confirmation_sent_at:         datetime
# unconfirmed_email:            string
# failed_attempts:              integer
# unlock_token:                 string
# locked_at:                    datetime
# following_branches_count:     integer

module Ddt
  class WebUser < Ddt::BaseUser
    include Ddt::CommentOwner
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :confirmable, :lockable, :timeoutable, authentication_keys: [:email, :shop_id]

    #we do not use builtin validatable, but use the following validation instead. by neil.

    validates :email, email: true, presence: true, uniqueness: { scope: [:shop_id, :type]}
    validates_presence_of     :password, :if => :password_required?
    validates_confirmation_of :password, :if => :password_required?
    validates_length_of       :password, within: 8..72, allow_blank: true

    after_update :save_name, :if => :need_save_name

    def to_label
      [self.phone, self.email, self.id].select(&:present?).join(" - ")
    end

    def self.find_for_authentication(warden_conditions)
      where(:email => warden_conditions[:email], :shop_id => warden_conditions[:shop_id]).first
    end

    def shop_host
      default_host = Rails.application.config.action_mailer.default_url_options[:host]
      host = self.shop.custom_host.present? ? self.shop.custom_host : [self.shop.slug, default_host].join(".")
    end

    private

    def save_name
      vip_info.update_attribute(:name, self.name)
    end

    def need_save_name
      self.name.present? && self.name != vip_info.name
    end


    def password_required?
      !persisted? || !password.nil? || !password_confirmation.nil?
    end

  end
end