module Ddt
  module Weixin
    class User::SignRecordsController < WeixinApplicationController
      respond_to :json
      def index
        @sign_records = @current_user.sign_records.paginate(page: params[:page])
        render json: @sign_records.map(&:created_at)
      end

      def create
        @sign_record = @current_user.sign
        if @sign_record.present?
          @current_user.reload
        else
          @sign_record = @current_user.sign_records.today.first
        end

        render json: {
          created_at: @sign_record.created_at,
          sign_records_count: @current_user.sign_records_count,
          continuous_sign_count: @current_user.continuous_sign_count
        }
      end
    end
  end
end