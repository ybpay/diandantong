module Ddt
  module OrderService
    module Order
      module Concern
        module BindScene
          extend ActiveSupport::Concern
          included do
            has_one :bind_qr_code_scene, ->{ of_builtin }, class_name: 'Ddt::QrCodeScene', as: :owner
            url_method_for :weixin_bind
          end

          def weixin_bind_path
            "/weixin/shops/#{self.shop_id}/bind_orders/#{self.id}"
          end

          def bind_qr_code_image
            self.create_bind_qr_code_scene(name: "#{self.class.name.demodulize} #{self.number}") if self.bind_qr_code_scene.nil?
            self.bind_qr_code_scene.url_variant(:medium)
          end
        end
      end
    end
  end
end