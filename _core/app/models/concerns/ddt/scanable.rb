module Ddt
  module Scanable
    extend ActiveSupport::Concern

    included do
      has_one :qr_code_scene, ->{ of_builtin }, class_name: 'Ddt::BaseQrCodeScene', as: :owner, dependent: :destroy

      ### callbacks
      after_create :create_qr_code
      delegate :scan_times, to: :qr_code_scene, allow_nil: true

      def qr_code_image
        self.qr_code_scene.try(:url).try(:to_s)
      end

      def create_qr_code
        if create_qr_code? && self.qr_code_scene.nil?
          QrCodeScene.of_builtin.create!(owner: self, name: "#{self.class.name.demodulize} #{self.name}") 
        end
      end

      def create_qr_code?
        true
      end

      def regenerate_qr_code
        self.qr_code_scene.destroy!
        self.reload
        create_qr_code
      end

      def enable_qr_code
        self.qr_code_scene.enable
      end

      def disable_qr_code
        self.qr_code_scene.disable
      end

    end
  end
end
