#encoding: utf-8
module Ddt
  module CommonApi
    module V1
      class PaymentsController < ActionController::Base
        # 支付通知
        def notify
          Rails.logger.tagged('PAYMENT', 'NOTIFY') do
            body = request.body.read
            Rails.logger.info "notify: payment_id=#{params[:id]}, params=#{params}, body=#{body}"
            case request.content_mime_type
              when Mime::XML
                request.params.merge! Hash.from_xml(body).deep_symbolize_keys
              when Mime::JSON
                request.params.merge! JSON.parse(body).deep_symbolize_keys
            end
            ::Ddt::Payment.transaction do
              payment = Ddt::Payment.with_discarded.where(id: params[:id]).lock(true).first
              Ddt::PaymentLog.log(payment, event: 'notify', extra: params.to_json)
              begin
                result = payment.notify(request)
                Rails.logger.info "notify_result: payment_id=#{params[:id]}, result=#{result}"
                Ddt::PaymentLog.log(payment, event: 'notify_success', extra: result.to_json)
                render plain: result[:content], status: 200, content_type: result[:content_type]
              rescue => error
                Rails.logger.error("notify_error: payment_id=#{params[:id]}, error=#{error}, backtrace=#{error.backtrace.join("\n")}.")
                Ddt::PaymentLog.log(payment, event: 'notify_error', extra: {exception_message: error.message}.to_json)
                ExceptionNotifier.notify_exception(error) if Rails.env.production?  # 在线环境则发邮件通知错误
                render plain: 'fail', status: 200, content_type: 'text/plain'
              end
            end
          end
        end
      end
    end
  end
end

