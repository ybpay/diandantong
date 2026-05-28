module Ddt
  class PayQrCodeScene < Ddt::BaseQrCodeScene
    extend FriendlyId
    friendly_id :slug, use: [:slugged, :finders]

    include Ddt::Attachable
    attachable_one :url, variants: { medium: [400, 400], thumb: [100, 100] }
    preference :pay_url, :text
    validates :preferred_pay_url, presence: true
    after_create :create_qrcode_url

    protected

    def create_qrcode_url
      generate_qr_code(self.preferred_pay_url, snap: true)
    end


  end
end
