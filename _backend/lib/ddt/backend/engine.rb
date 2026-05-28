module Ddt
  module Backend
    class Engine < ::Rails::Engine

      config.eager_load_paths += %W(#{config.root}/lib/ddt/backend/inputs)

      initializer "ddt.params.filter" do |app|
        app.config.filter_parameters += [:password, :password_confirmation, :pay_password]
      end

      initializer "static assets" do |app|
        app.middleware.use ::ActionDispatch::Static, "#{root}/public", 'max-age=604800'
      end

    end
  end
end
