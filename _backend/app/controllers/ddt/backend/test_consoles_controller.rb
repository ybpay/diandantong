module Ddt
  module Backend
    class TestConsolesController < Ddt::Backend::BaseController
      layout 'ddt/layouts/backend/test_console'
      before_action :check_env

      def valid_wechat_users
        @valid_wechat_users = @current_shop.users.search( unique_user_nickname_present: '1')
                                  .result.paginate(page: params[:page], per_page: params[:per_page] || 10)
      end

      def data_maker_panel

      end

      private
      def check_env
        raise 'available in development environment' unless Rails.env.development?
      end

    end
  end
end
