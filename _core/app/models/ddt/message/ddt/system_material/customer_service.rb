# encoding: utf-8
module Ddt
  module SystemMaterial
    class CustomerService < ::Ddt::SystemMaterial::Base
      def build_message
        if wechat_account.account_verified_service?
          message_reception.create_message_response!( msg_type: :transfer_customer_service )
        end
      end
    end
  end
end
