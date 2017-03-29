module Ddt
  module Agentsys
    class Engine < ::Rails::Engine
      # config.assets.paths << config.root.join("vendor/assets/")

      config.autoload_paths += %W(#{config.root}/lib/)
      # filter sensitive information during logging
      initializer "ddt.params.filter" do |app|
        app.config.filter_parameters += [:password, :password_confirmation, :pay_password]
      end

      # sets the manifests / assets to be precompiled, even when initialize_on_precompile is false
      initializer "ddt.assets.precompile", :group => :all do |app|
        app.config.assets.precompile += %w[
          ddt/agentsys.css ddt/agentsys.js
        ]
      end

    end
  end
end
