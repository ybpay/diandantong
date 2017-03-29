module Ddt
  module InnerApi
    class FeatureModuleGroupsController < InnerApi::BaseController
      def index
        @feature_module_groups = Ddt::FeatureModuleGroup.all_values_without_base
      end
    end
  end
end