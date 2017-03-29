module Ddt
  class QrcodeScanRelation < Ddt::Base
    belongs_to :base_qr_code_scene, class_name: 'Ddt::BaseQrCodeScene'
    belongs_to :scaner, polymorphic:  true
    validates_presence_of :base_qr_code_scene, :scaner
    validates_uniqueness_of :base_qr_code_scene_id, scope: [:scaner_id, :scaner_type]

    after_create do
      self.base_qr_code_scene.increment!(:qrcode_scaners_count)
    end
  end
end