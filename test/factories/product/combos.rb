FactoryGirl.define do
  factory :combo, class: Ddt::Combo do
    name
    shop_id 1
    branch_id 1
    description "description"
    unit_name "份"
    availabled_at { 1.hour.ago }
    price 10.00
    vip_price 10.00
    factory :combo_with_items, class: Ddt::Combo do
      transient do
        items_count 1
      end
      after :create do |combo, evaluator|
        create_list(:combo_item, evaluator.items_count, combo: combo, branch_id: combo.branch_id)
      end
    end
    factory :combo_with_package, class: Ddt::Combo do
      transient do
        items_count 1
      end
      after :create do |combo, evaluator|
        create_list(:combo_item, evaluator.items_count, combo: combo, branch_id: combo.branch_id)
        items = combo.combo_items.map{|item|
          {
            combo_item_id: item.id,
            variant_id: item.variants.first.id,
            quantity: 1
          }
        }
        combo.add_combo_package(items)
      end
    end
  end
end
