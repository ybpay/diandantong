module Ddt
  module InnerApi
    class Engine < ::Rails::Engine

      initializer "ddt.params.filter" do |app|
        app.config.filter_parameters += [:password, :password_confirmation, :pay_password]
      end

      config.before_initialize do
        ActiveSupport.on_load :action_controller do
          helper Ddt::Core::Engine.helpers
          helper Ddt::Core::Engine.routes.url_helpers
        end
      end

    end
  end
end
