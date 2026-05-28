module Ddt
  module Api
    module V1
      module Agentsys
        class PlansController < BaseController
          def index
            groups = Ddt::FeatureModuleGroup.all.map do |key|
              group = Ddt::FeatureModuleGroup.send(key)
              {
                id: key.to_s,
                name: group[:label],
                price: group[:price].to_f,
                modules: group[:modules]
              }
            end
            render json: groups
          end
        end
      end
    end
  end
end
