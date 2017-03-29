module Ddt
  module SendTemplateMessage
    extend ActiveSupport::Concern

    # message {template_id, url, data}
    def send_template_message(access_token, user_open_id, message)
      if access_token.present? && user_open_id.present?
        Rails.logger.warn "send template message to user_open_id #{user_open_id}, access_token #{access_token}, message #{message}"
        begin
          WeixinApi.send_template_message(
            access_token,
            user_open_id,
            message[:template_id],
            message[:url],
            message[:data])
          return true
        rescue WeixinApi::WeixinApiError => e
          if e.errcode > 0
            params = [access_token, user_open_id, message[:template_id], message[:data]].join(',')
            puts "#{params}"
            puts "#{e.message}"
            Rails.logger.error "WeixinApi.send_template_message send system message failed, #{params} , #{e.message}"
          end
          return false
        end
      end
    end

  end
end
