module Ddt
  class QrCodeScene < Ddt::BaseQrCodeScene

    extend FriendlyId
    friendly_id :slug, use: [:slugged, :finders]
    include Ddt::Attachable
    attachable_one :url, variants: { medium: [400, 400], thumb: [100, 100] }
    preference :redirect_url, :text
    validates :preferred_redirect_url, presence: true, unless: :builtin? #系统生成的二维码允许跳转链接为空
    belongs_to :qr_code_assign_log, class_name: 'QrCodeAssignLog'
    after_create :create_qrcode_url

    def qr_url 
      qr_path = Ddt::Core::Engine.routes.url_helpers.qr_code_path(self.slug)
      # Rails.logger.info(Rails.application.routes.url_helpers.ddt_url)
      # Rails.logger.info(qr_path)
      URI.join(Rails.application.routes.url_helpers.ddt_url, qr_path).to_s
    end
    protected

    def create_qrcode_url
      self.qr_url
      generate_qr_code(qr_url)
    end

  end
end