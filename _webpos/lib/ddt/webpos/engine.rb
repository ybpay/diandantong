module Ddt
  module Webpos
    class Engine < ::Rails::Engine

      # config.autoload_paths += %W(#{config.root}/lib/ddt/backend/inputs)
      config.assets.paths << config.root.join("vendor/assets/jvk/")

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
          ddt/webpos.css
          ddt/common.js
          ddt/webpos.js
          ddt/webpos_kitchen.css
          ddt/webpos_kitchen.js
          ddt/webpos_users.css
          ddt/webpos_users.js
          ddt/webpos_queue.css
          ddt/webpos_queue.js
          ddt/webpos_bill.css
          ddt/webpos_bill.js
          ddt/webpos_estimate.css
          ddt/webpos_estimate.js
          ddt/webpos/angular_lib.js
          thirdparty/_base.js
          thirdparty/_surface.js
          thirdparty/_webpos.js
          ddt/extended_form.js
          ddt/extended_form.css
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
