require "test_helper"
module Ddt
  module CommonApi
    module V1
      class AccountsControllerTest < TestCase::Controller::CommonApi
        setup do
          logout
        end

        def test_index
          login_as worker
          get :index
          assert_response 200
          assert_respond_to json, :size
        end

        def test_create
          login_as boss
          account_num_was = shop.accounts.size
          post :create, account: {
            login_id: 'login_id',
            password: 'abcd1234',
            password_confirmation: 'abcd1234',
            name: 'account_name',
            phone: '13213213250',
            email: 'test@tset.com',
          }
          assert_response 200
          account_num_now = shop.reload.accounts.size
          assert_equal 1, account_num_now - account_num_was
        end

        def test_update
          login_as boss
          @account = shop.accounts.last
          post :update, p(id: @account.id, account: {
            name: 'demo12345',
          })
          assert_response 200
          assert_equal 'demo12345', @account.reload.name
        end

        def test_destroy
          login_as boss
          @a = create_account
          post :destroy, p(id: @a.id)
          assert_response 200
          assert @a.reload.destroyed?
        end

        def test_login
          get :login, login_id: worker.login_id, password: "12345678"
          assert_response 200
          assert_equal worker.id, json["id"]
        end

        def test_login_with_params_token
          get :show, login_id: worker.login_id, authentication_token: worker.authentication_token
          assert_response 200
        end

        def test_login_with_header_token
          login_as worker
          get :show
          assert_response 200
        end

        def test_login_with_update_push_channel
          get :login, login_id: worker.login_id, password: "12345678",  channel_id: "1a1018970aa5ab2e763", os_type: "ios"
          assert_response 200
          assert_equal worker.id, json["id"]
          assert_equal "1a1018970aa5ab2e763", worker.push_channels.first.j_push_channel_id
        end

        def test_without_login
          get :show
          assert_response 401
          assert_equal json["error_code"], "11"
        end

        def test_login_with_expired_token
          worker.update(authentication_token_expired_at: 1.day.ago)
          login_as worker
          get :show
          assert_response 401
          assert_equal json["error_code"], "12"
        end

        def test_show
          login_as worker
          get :show
          assert_response 200
          assert worker.id, json["id"]
        end

        def test_send_sms_captcha
          Ddt::ShortMessage.any_instance.stubs(:send_short_message).returns(true)
          assert_change "Ddt::SmsCaptcha.count" do
            post :send_sms_captcha, phone: "1388888"
          end
          assert_response 200
          assert_equal json['captcha_id'], Ddt::SmsCaptcha.last.id
        end

        def test_register
          Ddt::ShortMessage.any_instance.stubs(:send_short_message).returns(true)
          captcha = SmsCaptcha.create(phone: "1388888", ip: "8.8.8.8", session_hash: "asdf")
          assert_change ["Ddt::Account.count", "Ddt::Shop.count"] do
            post :register, login_id: "newlogin", name: "name", email: "test@test.com", phone: "1388888", password: "12345678", password_confirmation: "12345678", captcha_id: captcha.id, captcha: captcha.code
            assert_equal json['id'], Ddt::Account.last.id
          end
        end

        private

        def create_account
          a = Ddt::Account.new(
            shop_id: shop.id,
            login_id: 'account_to_del',
            password: 'abcd1234',
            password_confirmation: 'abcd1234',
            name: 'account_to_del',
            phone: '39395949321',
            email: 'to_del@tset.com'
          )
          a.captcha_valid = true
          a.save
          return a
        end
      end
    end
  end
end
