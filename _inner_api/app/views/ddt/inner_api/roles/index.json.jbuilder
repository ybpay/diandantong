json.array! @roles do |role|
  json.extract! role, :id, :name, :display_name, :permission_set, :description
end