json.array!(@form_elements) do |form_element|
  json.extract! form_element, :id, :type, :statement, :regex, :sequence, :form_element_id, :branch_id, :deleted_at
  json.url form_element_url(form_element, format: :json)
end
