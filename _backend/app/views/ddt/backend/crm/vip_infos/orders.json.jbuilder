json.array! @logs do |log|
  json.(log, :id, :number, :shop_id, :total, :state_name, :placed_at,:paid_at)
  json.branchname log.branch.name
end