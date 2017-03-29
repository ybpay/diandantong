module Ddt
  module Backend
    class SignRecordsController < Ddt::Backend::BaseController
      check_permission :shop, :sign_record, :show

      def index
        @q = @current_shop.sign_records.ransack(params[:q])
        @sign_records = @q.result.paginate(page: params[:page])
      end

    end
  end
end