# encoding: utf-8
module Ddt
  class WeixinTestCustomMessageWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 5, :queue => :default

    def perform(to_user_open_id, authorizer_access_token, query_auth_code)
      material = Ddt::Material.new(msg_type: :text, content: "#{query_auth_code}_from_api")
      Ddt::WeixinApi.send_custom_message(material, to_user_open_id, authorizer_access_token)
    end

  end
end
