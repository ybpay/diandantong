module Ddt
  module OrderService
    module Order
      module Concern
        module BindSceneTest
          extend ActiveSupport::Concern

          def test_bind_qr_code_image
            order.bind_qr_code_image
            assert order.bind_qr_code_scene.present?
          end
        end
      end
    end
  end
end