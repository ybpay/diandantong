json.array! @register_forms do |register_form|
  json.extract! register_form, :id, :phone, :name, :email, :track_from_name, :track_from
  json.created_at register_form.created_at.strftime("%F %T")
end