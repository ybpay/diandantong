FactoryGirl.define do
  factory :combo_item, class: Ddt::ComboItem do
    name
    branch_id 1
    shop_id 1
    combo
    after :create do |combo_item|
      combo_item.variants << create(:product, shop_id: combo_item.shop_id, branch_id: combo_item.branch_id).master
    end
  end
end
