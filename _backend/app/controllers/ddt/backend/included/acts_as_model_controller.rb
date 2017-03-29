module Ddt
  module Backend
    module Included
      module ActsAsModelController
        def self.included(mod)
          mod.before_action do
            @model_name = controller_name.singularize
            @model_class = "Ddt::#{@model_name.camelize}".constantize
          end
        end
      end
    end
  end
end