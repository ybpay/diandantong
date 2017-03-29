json.cache! @form_elements, expires_in: 1.day do
  json.array! @form_elements do |form_element|
    json.id form_element.id
    json.label form_element.statement
    json.type form_element.type
    json.placeholder form_element.placeholder if form_element.placeholder.present?
    #json.need form_element.need if form_element.need && form_element.need.present?
    json.support_order_types form_element.support_order_types
    if form_element.options.present?
      json.options form_element.options do |option|
        json.option_id option.id
        json.html option.statement
      end
      json.options_hash Hash[form_element.options.map { |o| [o.id, o.statement] } ]
    end
    json.need form_element.need

    if form_element.is_a? Ddt::FormElementText
      json.record do
        json.type form_element.type
        json.form_element_id form_element.id
        json.content ""
      end
    end
    if form_element.is_a? Ddt::FormElementSelect
      json.record do
        json.type form_element.type
        json.form_element_id form_element.id
      end
    end
  end
end