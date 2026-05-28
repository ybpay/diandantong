module Ddt
  class VerifyVipInfoQrCodeScene < Ddt::BaseQrCodeScene
    extend FriendlyId
    friendly_id :slug, use: [:slugged, :finders]

    include Ddt::Attachable
    attachable_one :url, variants: { medium: [400, 400], thumb: [100, 100] }
    preference :terminal_id, :string
    preference :account_id, :string
    preference :vip_only, :boolean

    validates :preferred_terminal_id, presence: true
    validates :preferred_account_id,presence: true
    after_create :create_qrcode_url

    protected

    def create_qrcode_url
      qr_path = Ddt::Core::Engine.routes.url_helpers.common_shop_verify_vip_info_qr_code_scene_path(self.shop_id, self)
      qr_url = URI.join(Rails.application.routes.url_helpers.ddt_url, qr_path).to_s
      generate_qr_code(qr_url, snap: true)
    end

  end
end
