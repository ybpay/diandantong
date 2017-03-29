FactoryGirl.define do
  factory :form_element, class: Ddt::FormElement do
    shop_id 1
    branch_id 1
    statement
    placeholder "placeholder"
    need false
    support_delivery true
    support_eat_in_hall true
    support_reservation true
    factory :form_element_text, class: Ddt::FormElementText do
    end
    factory :form_element_select, class: Ddt::FormElementSelect do
      after :create do |form_element_select|
        form_element_select.form_elements << create(:form_element_option)
        form_element_select.form_elements << create(:form_element_option)
      end
    end
  end

  factory :form_element_option, class: Ddt::FormElementOption do
    shop_id 1
    branch_id 1
    statement
    placeholder "placeholder"
  end
end
