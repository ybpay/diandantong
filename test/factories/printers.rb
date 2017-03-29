FactoryGirl.define do
  factory :normal_printer, class: Ddt::Printer::Normal do
    shop_id 1
    branch_id 1
    name
    number "10001"
    use_scene "webpos"
    print_spec "80"
    token "ddt"
  end
end
