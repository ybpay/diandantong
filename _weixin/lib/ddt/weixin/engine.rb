module Ddt
  module Weixin
    class Engine < ::Rails::Engine

      # config.autoload_paths += %W(#{config.root}/lib/ddt/backend/inputs)

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
        app.config.assets.precompile += %w[
          ddt/common.css
          ddt/main.css
          ddt/my.css
          ddt/cart.css
          ddt/order.css
          ddt/queue.css
          thirdparty/zepto.min.js
          ddt/thirdparty.js
          ddt/business-s.js
          ddt/business-main.js
          ddt/business-my.js
          ddt/business-cart.js
          ddt/business-order.js
          ddt/business-queue.js
          ddt/business-manage.js
        ]
      end
      initializer "static assets" do |app|
        # app.middleware.use ::ActionDispatch::Static, "#{root}/vendor"
        app.middleware.use ::ActionDispatch::Static, "#{root}/public", 'max-age=604800'
        # config.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
      end
    end
  end
end
