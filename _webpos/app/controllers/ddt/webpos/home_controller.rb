module Ddt
  module Webpos
    class HomeController < Webpos::BaseController
      skip_before_action :authenticate_webpos_webpos_account!, only: [:index, :kitchen, :users, :queue, :bill, :estimate]
      before_action :set_account_info
      def index
        respond_to do |format|
          format.html { render :index, layout: "ddt/layouts/webpos/webpos" }
        end
      end

      def kitchen
        respond_to do |format|
          format.html { render :index, layout: "ddt/layouts/webpos/kitchen" }
        end
      end

      def users
        respond_to do |format|
          format.html { render :index, layout: "ddt/layouts/webpos/users" }
        end
      end

      def queue
        respond_to do |format|
          format.html { render :index, layout: "ddt/layouts/webpos/queue" }
        end
      end

      def bill
        respond_to do |format|
          format.html { render :index, layout: "ddt/layouts/webpos/bill" }
        end
      end

      def estimate
        respond_to do |format|
          format.html { render :index, layout: "ddt/layouts/webpos/estimate" }
        end
      end

      private
      def set_account_info
        if current_account.present?
          @account = current_account
          @account_info = render_to_string( :template => 'ddt/webpos/accounts/show.json.jbuilder')
        end
      end
    end
  end
end
