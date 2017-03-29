# encoding : utf-8
module Ddt
  class Common::JsErrorReportController < ApplicationController
    protect_from_forgery :except => :create

    def create
      @js_error = JsError.new(js_error_params)
      @js_error.agent = request.user_agent[0..255]

      # 截断与聚合
      # TODO 聚合
      @js_error.error_message = @js_error.error_message[0..5000]
      @js_error.stack_trace = @js_error.stack_trace.join("\n")[0..5000]
      @js_error.generate_digest

      # 保存错误
      old_error = JsError.where(digest: @js_error.digest).detect {|it| it.same?(@js_error)}

      JsError.transaction do
        error_saved = if old_error.present?
          @js_error = old_error
          @js_error.increment! :count
        else
          @js_error.save
        end

        # 保存对 IP 的错误计数
        count_saved = if error_saved
          ip = request.headers['X-Forwarded-For'] unless ip.present?
          ip = request.headers['X-Real-Ip'] unless ip.present?
          ip = request.env['REMOTE_ADDR'] unless ip.present?
          ip = ip.split(',')[0].strip if ip
          @js_error.js_error_counts.find_or_create_by(ip: ip).increment!(:count)
        else
          false
        end

        unless error_saved and count_saved
          Rails.logger.error "插入JSError异常, error_saved=#{error_saved} count_saved=#{count_saved}, #{@js_error.inspect}"
        end
      end

      head :no_content
    end

    private

    # Never trust parameters from the scary internet, only allow the white list through.
    def js_error_params
      params.require(:js_error).permit(:app_name, :url, :agent, :error_message, :cause, :stack_trace => [])
    end
  end
end