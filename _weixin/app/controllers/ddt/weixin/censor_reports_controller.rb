module Ddt
  class Weixin::CensorReportsController < WeixinApplicationController

    def create
      @censor_report = CensorReport.new(censor_report_params)
      @censor_report.shop = @current_shop
      @censor_report.base_user = @current_user
      if @censor_report.save
        render :json => {success: true}
      else
        render json: {errors: @censor_report.errors.full_messages}, status: :bad_request
      end
    end

    private
    def censor_report_params
      params.require(:censor_report).permit(:title, :desc)
    end

    rescue_from ActionController::ParameterMissing do |e|
      render json: {errors: e.message}, status: :bad_request
    end

  end
end