module Ddt
  module Host
    DEPLOY = Rails.application.default_url_options[:host]
    LOCAL = 'localhost'
    ASSET = Rails.configuration.action_controller.asset_host
  end
end
