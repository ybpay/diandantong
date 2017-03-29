json.array! @discount_plans do |discount_plan|
  json.(discount_plan, :id, :name, :desc)
end