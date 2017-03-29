#encoding: utf-8
module Ddt
  module RechargeRestriction
    extend ActiveSupport::Concern
    included do
    end

    def can_apply_to_shop?(shop, apply_type)
      # shop_type   applicable_lisence_types
        case shop.shop_type
        when nil       then true
        when 'standard'then %W[mini standard chain multiple].include? apply_type
        when 'mini'    then %W[mini standard chain multiple].include? apply_type
        when 'chain'   then apply_type == 'chain'
        when 'multiple' then apply_type == 'multiple'
        when 'base'    then apply_type == 'base'   
        end
    end

  end
end
