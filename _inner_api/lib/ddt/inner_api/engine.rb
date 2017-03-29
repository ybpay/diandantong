module Ddt
  module InnerApi
    class Engine < ::Rails::Engine

      # filter sensitive information during logging
      initializer "ddt.params.filter" do |app|
        app.config.filter_parameters += [:password, :password_confirmation, :pay_password]
      end

      config.before_initialize do
        ActiveSupport.on_load :action_controller do
          helper Ddt::Core::Engine.helpers
          helper Ddt::Core::Engine.routes.url_helpers
        end
      end

      # sets the manifests / assets to be precompiled, even when initialize_on_precompile is false
      initializer "ddt.assets.precompile", :group => :all do |app|
        # config.assets.precompile = [ /\A[^\/\\]+\.(css|scss|js)$/i ]
        
      end
      initializer "static assets" do |app|
        # app.middleware.use ::ActionDispatch::Static, "#{root}/vendor"
        # app.middleware.use ::ActionDispatch::Static, "#{root}/public", 'max-age=604800'
        # config.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
      end
    end
  end
end
