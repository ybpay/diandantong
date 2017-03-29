module Ddt
  class QrCodeSceneBatchCreateWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 10, :queue => :default

    def perform(count)
      count.times do 
          qr_code_scene = Ddt::QrCodeScene.new(slug: Ddt::BaseQrCodeScene.generate_slug)
          # qr_code_scene.skip_callbacks(:create) {false}
          qr_code_scene.send(:create_qrcode_url)
          qr_code_scene.save(validate: false)
        end
    end
  end
end

