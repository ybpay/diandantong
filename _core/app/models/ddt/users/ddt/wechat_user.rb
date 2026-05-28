module Ddt
  class WechatUser < Ddt::Base
    include Discard::Model
    default_scope { kept }

    ### relationships
    include Ddt::BelongsToShop
    belongs_to :user, class_name: 'Ddt::User'
    has_many :qrcode_scan_relations, as: :scaner, class_name: "Ddt::QrcodeScanRelation"

    ### validations
    validates :gonghao_open_id, :presence => true, gonghao: true
    validates :user_open_id, presence: true, :uniqueness => { scope: [:gonghao_open_id, :discarded_at, :shop_id] }
    validates :user_id, :unchangable_after_save => true

    delegate :headimgurl, :nickname, :sex, :sex_name, :unique_user, :to_label, to: :user, allow_nil: true

    ### callbacks

    ### scopes
    scope :subscribed, ->{ where(unsubscribed_at: nil)}
    scope :unsubscribed, ->{ where.not(unsubscribed_at: nil)}

    SOURCE_OF_OAUTH  = 'oauth' #oauth授权
    SOURCE_OF_MESSAGE  = 'message'  #微信自动回复

    ### methods
    #source:  OAuth/Message,定义创建用户的来源，从而了解可以确定该用户是否已关注，已关注这一原因对于发送微信消息很重要
    def self.get_wechat_user(shop, gonghao_open_id, user_open_id, source)
        if source == SOURCE_OF_OAUTH
          shop.wechat_users.where(
            user_open_id: user_open_id,
            gonghao_open_id: gonghao_open_id).first_or_create!(unsubscribed_at: DateTime.now) #自动创建未关注用户
        elsif source == SOURCE_OF_MESSAGE
            shop.wechat_users.where(
            user_open_id: user_open_id,
            gonghao_open_id: gonghao_open_id).first_or_create!(unsubscribed_at: nil) #自动创建已关注用户
        else
            raise 'invalid source of wechat user'
        end
    end

    def wechat_account
        self.shop.wechat_accounts.where(:gonghao_open_id => self.gonghao_open_id).first rescue nil
    end


    def system_user_json
        {id: self.user_id, name: self.to_label}
    end

    def name
      user.name
    end

    def subscribed?
      self.unsubscribed_at.blank?
    end

    def unsubscribed?
      self.unsubscribed_at.present?
    end

  end
end
