FactoryGirl.define do
  factory :essential_product, class: Ddt::EssentialProduct do
    shop_id 1
    branch_id 1
    variant
    per_guest false
    quantity 1
  end
end
