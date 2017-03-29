require 'test_helper'
module Ddt
  module Common
    class QrCodeScenesControllerTest < TestCase::Controller::Weixin
      let(:queue_setting) { create :queue_setting, branch: branch, shop: shop }
      let(:guest_queue) { queue_setting.new_guest_queue(base_user: nil, guest_num: 1, phone: "123123123")}

      def test_scan_table_store_table_id_to_session
        Ddt::QrCodeScene.of_builtin.create(owner: table, name: "Table #{table.name}")
        get :show, p(id: table.reload.qr_code_scene.id)
        assert_equal session[:store_type], 'for_merge_order'
        assert_equal session[:table_id], table.id
      end

      def test_scan_guest_queue
        get :show, p(id: guest_queue.qr_code_scene.id)
        assert_equal session[:store_type], 'for_pre_order'
        assert_equal session[:guest_queue_id], guest_queue.id
      end


    end
  end
end
