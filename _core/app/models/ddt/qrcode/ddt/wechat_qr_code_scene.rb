# encoding: utf-8
module Ddt
  class WechatQrCodeScene < Ddt::BaseQrCodeScene

    extend FriendlyId
    friendly_id :slug, use: [:slugged, :finders]
    validates_numericality_of :scene_id, {:greater_than_or_equal_to =>1}
    validates :gonghao_open_id, presence:true
    validates :url, presence: true
    before_validation :obtain_qrcode_url, on: :create

    acts_as_type :wechat_scene_type, [:limit, :snap], %W[永久 临时]
    acts_as_type :snap_scene_type, [:queue], %W[排号]
    acts_as_type :limit_scene_type, [:material_message, :branch_message, :queue_message, :fastfood_message], %W[素材消息 门店链接 门店排号链接 门店快餐链接]
    belongs_to :material, class_name: "Ddt::Material"
    belongs_to :branch, class_name: "Ddt::Branch"

    def wechat_account
      self.shop.wechat_accounts.find_by(:gonghao_open_id => self.gonghao_open_id)
    end

    protected
    def generate_scene_id
      self.shop.increment!(:last_scene_id)
      self.shop.last_scene_id
    end

    def obtain_qrcode_url
      if self.is_limit? && self.scene_id.nil?
        self.scene_id = self.generate_scene_id
      elsif self.is_snap? && self.scene_id.present?
        self.scene_id += 100000
      end
      if self.shop.primary_wechat_account
        if self.gonghao_open_id.present?
          access_token = self.wechat_account.get_access_token
        else
          self.gonghao_open_id = self.shop.primary_wechat_account.gonghao_open_id
          access_token = self.shop.primary_wechat_account.get_access_token
        end
        begin
          if self.is_limit?
            self.url = Ddt::WeixinApi.create_limit_qr_code(access_token, self.scene_id)
          elsif self.is_snap?
            self.url = Ddt::WeixinApi.create_snap_qr_code(access_token, self.scene_id)
          end
        rescue => e
          self.errors.add(:base, e.message)
        end
      else
        raise 'primary wechat account is not primary account'
      end
    end
  end
end
