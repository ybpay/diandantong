module Ddt
  module PromotionActionModelName
    extend ActiveSupport::Concern
    included do
    end

    module ClassMethods
      def model_name
        Ddt::PromotionAction.model_name
      end
    end
  end
end