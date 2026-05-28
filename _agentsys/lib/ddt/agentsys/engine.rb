module Ddt
  module Agentsys
    class Engine < ::Rails::Engine

      config.eager_load_paths += %W(#{config.root}/lib/)

      initializer "ddt.params.filter" do |app|
        app.config.filter_parameters += [:password, :password_confirmation, :pay_password]
      end

    end
  end
end
