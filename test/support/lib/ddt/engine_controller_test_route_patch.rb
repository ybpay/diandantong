module Ddt
  module EngineControllerTestRoutePatch
    extend ActiveSupport::Concern
    module ClassMethods
      def engine_route_patch(params)
        [:get, :put, :post, :delete].each do |method|
          define_method "#{method}_with_patch" do |action, parameters={}, session=nil, flash=nil|
            send("#{method}_without_patch", action, parameters.reverse_merge(params), session, flash)
          end
          alias_method "#{method}_without_patch", method
          alias_method method, "#{method}_with_patch"
        end
      end
    end
  end
end