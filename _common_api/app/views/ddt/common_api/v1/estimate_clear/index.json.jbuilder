json.array! @variants do |variant|
  json.name variant.name_with_options_text
  json.id   variant.id
  json.stock_quantity variant.stock_quantity
  json.estimate_clear_reciprocal variant.estimate_clear_reciprocal
end
