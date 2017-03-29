json.array! @logs do |log|
  json.(log, :id, :owner_name, :created_at, :reason_name,
  :display_amount, :cash_amount, :extra_amount, :note )
  json.order_number log.try(:order).try(:number)
end