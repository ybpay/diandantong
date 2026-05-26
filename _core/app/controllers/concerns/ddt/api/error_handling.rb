module Ddt
  module Api
    module ErrorHandling
      extend ActiveSupport::Concern

      included do
        rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
        rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable
        rescue_from ActionController::ParameterMissing, with: :render_bad_request
        rescue_from Ddt::PaymentException, with: :render_payment_error
        rescue_from Ddt::Error::NoPermissionError, with: :render_forbidden
        rescue_from Ddt::Error::NoFeatureError, Ddt::Error::FeatureNotEnabled, with: :render_feature_disabled
        rescue_from Ddt::OrderService::Api::UpdateLockError, with: :render_conflict

        rescue_from Ddt::Api::AuthenticationError, with: :render_unauthorized
        rescue_from Ddt::Api::TokenExpiredError, with: :render_token_expired
        rescue_from Ddt::Api::ForbiddenError, with: :render_forbidden
      end

      private

      def render_not_found(exception)
        render_error(:not_found, "资源不存在",
          detail: exception.message,
          code: "NOT_FOUND")
      end

      def render_unprocessable(exception)
        errors = exception.record.errors.map do |error|
          { source: { pointer: "/data/attributes/#{error.attribute}" }, detail: error.message }
        end
        render json: { errors: errors }, status: :unprocessable_entity
      end

      def render_bad_request(exception)
        render_error(:bad_request, "参数非法",
          detail: exception.message,
          code: "PARAMETER_MISSING")
      end

      def render_payment_error(exception)
        render_error(:bad_request, exception.message,
          code: "PAYMENT_ERROR",
          meta: exception.log_json_entry)
      end

      def render_forbidden(exception)
        render_error(:forbidden, exception.message,
          code: "FORBIDDEN")
      end

      def render_feature_disabled(exception)
        render_error(:forbidden, exception.message,
          code: "FEATURE_DISABLED")
      end

      def render_conflict(_exception)
        render_error(:conflict, "操作冲突，请重试",
          code: "CONFLICT")
      end

      def render_unauthorized(_exception)
        render_error(:unauthorized, "认证失败",
          code: "AUTH_FAILED")
      end

      def render_token_expired(_exception)
        render_error(:unauthorized, "Token已过期，请重新登录",
          code: "TOKEN_EXPIRED")
      end

      def render_error(status, title, code:, detail: nil, meta: nil)
        error = { status: Rack::Utils::SYMBOL_TO_STATUS_CODE[status], title: title, code: code }
        error[:detail] = detail if detail
        error[:meta] = meta if meta
        render json: { errors: [error] }, status: status
      end
    end
  end
end
