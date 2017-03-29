require 'test_helper'
module Ddt
  module CommonApi
    module V1
      class LabelsControllerTest < TestCase::Controller::CommonApi

        def test_subtract
          get :subtract, p
          assert_response 200
          assert_respond_to json, :size
        end

        def test_gift
          get :gift, p
          assert_response 200
          assert_respond_to json, :size
        end

        def test_service
          get :service, p
          assert_response 200
          assert_respond_to json, :size
        end

      end
    end
  end
end
