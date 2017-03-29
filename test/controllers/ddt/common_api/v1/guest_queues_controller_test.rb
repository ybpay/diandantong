require 'test_helper'
module Ddt
  module CommonApi
    module V1
      class GuestQueuesControllerTest < TestCase::Controller::CommonApi

        def setup
          Ddt::ArrangingSetting.destroy_all
          queue_setting.update!(start_at: 1.minute.ago, end_at: 1.minute.since)
          @queue_setting2 = create(:queue_setting, shop_id: shop.id, branch_id: branch.id, guest_num_le: 2, start_at: 1.minute.ago, end_at: 1.minute.since)
        end

        def test_index
          get :index, branch_id: branch.id
          assert_response 200
        end

        def test_create_with_free_choice
          arranging_setting.update!(mode: 'free_choice')
          post_create
          assert_equal queue_setting.id, json['queue_setting_id']
        end

        def test_create_with_auto_assigned
          arranging_setting.update!(mode: 'auto_assigned')
          post_create
          assert_equal @queue_setting2.id, json['queue_setting_id']
        end

        def post_create
          post :create, p(
            queue_setting_id: queue_setting.id,
            guest_queue: {
              guest_num: 2,
              queue_setting_id: queue_setting.id,
              phone: '13298584350'
            }
          )
          assert_response 200
        end

        def test_accept
          get :accept, params
          assert_response 200
          assert_equal 'accepted', workflow_state
        end

        def test_pass
          get :pass, params
          assert_response 200
          assert_equal 'past', workflow_state
        end

        def test_cancel
          get :cancel, params
          assert_response 200
          assert_equal 'canceled', workflow_state
        end

        def test_requeue
          guest_queue.pass!
          get :requeue, params
          assert_response 200
          assert_equal 'queueing', workflow_state
        end

        def test_notify
          get :notify, params
          assert_response 200
        end

        def test_reprint
          get :reprint, params
          assert_response 200
        end

        def test_print_pre_order
          get :print_pre_order, params
          assert_response 200
        end

        def test_show
          get :show, params
          assert_response 200
          assert_equal guest_queue.id, json['id']
        end

        def workflow_state
          json['workflow_state']
        end

        def params
          {shop_id: shop.id, branch_id: branch.id, queue_setting_id: queue_setting.id, id: guest_queue.id}
        end

      end
    end
  end
end
