FactoryGirl.define do
  factory :order_promotion, class: Ddt::OrderPromotion do
    shop_id 1
    name
    # usage_limit 100
    description "description"
    keywords "keywords"
    match_policy :match_all
    branch_scope_policy :match_all_branches
    factory :order_promotion_in_branch, class: Ddt::OrderPromotion do
      branch_id 1
    end
  end

  [:combo, :first_order_in_branch, :first_order_in_shop, :item_total, :one_use_per_user, :order_in_time_range, :pay_method, :variant].each do |name|
    factory "promotion_rules_order_#{name}", class: Ddt::Promotion::Rules::Order.const_get(name.to_s.camelize) do
      shop_id 1
    end
  end

  factory :promotion_actions_order_free_shipping, class: Ddt::Promotion::Actions::Order::FreeShipping do
    shop_id 1
  end

  factory :promotion_actions_order_create_adjustment, class: Ddt::Promotion::Actions::Order::CreateAdjustment do
    shop_id 1
    factory :promotion_actions_order_create_adjustment_with_flat_reduce_calculator, class: Ddt::Promotion::Actions::Order::CreateAdjustment do
      calculator { Ddt::Calculator::Order::FlatReduce.create }
      transient do
        flat_reduce_amount 1
      end
      after :create do |promotion_action, evaluator|
        calculator = promotion_action.calculator
        calculator.preferred_flat_reduce_amount = evaluator.flat_reduce_amount
        calculator.save
      end
    end
  end

  factory :promotion_actions_order_item_discount, class: Ddt::Promotion::Actions::Order::ItemDiscount do
    shop_id 1
    preferred_discount 90
  end

end
