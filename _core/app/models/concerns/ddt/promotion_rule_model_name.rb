module Ddt
  module PromotionRuleModelName
    extend ActiveSupport::Concern
    included do
    end

    module ClassMethods
      def model_name
        Ddt::PromotionRule.model_name
      end
    end
  end
end