module Ddt
  module Backend
    class Engine < ::Rails::Engine

      config.eager_load_paths += %W(#{config.root}/lib/ddt/backend/inputs)
      config.assets.paths << config.root.join("vendor/assets/ace/")
      config.assets.paths << config.root.join("vendor/assets/javascripts/")
      config.assets.paths << config.root.join("vendor/assets/stylesheets/")
      config.assets.paths << config.root.join("public/audios/")
      config.assets.paths << config.root.join("public/fonts/")


      # filter sensitive information during logging
      initializer "ddt.params.filter" do |app|
        app.config.filter_parameters += [:password, :password_confirmation, :pay_password]
      end

      # sets the manifests / assets to be precompiled, even when initialize_on_precompile is false
      initializer "ddt.assets.precompile", :group => :all do |app|
        app.config.assets.precompile += %w[
          *.eof *.eot *.ttf *.svg *.swf *.woff *.woff2 *.gif ddt/images/* ddt/weui-1.0.2.css ddt/basic.css ddt/backend.css ddt/backend_weixin.css ddt/backend.js ddt/backend_weixin.js ddt/login.css ddt/backend_crm.js ddt/backend_crm.css ddt/basic.css ddt/login.js ddt/basic.js
        ]
        # vendor assets
        app.config.assets.precompile += %W[avatars/*  images/* img/*]
      end
      initializer "static assets" do |app|
        app.middleware.use ::ActionDispatch::Static, "#{root}/public", 'max-age=604800'
      end

    end
  end
end
