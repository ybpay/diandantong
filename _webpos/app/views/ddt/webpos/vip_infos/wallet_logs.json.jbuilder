json.array! @wallet_logs do |wallet_log|
  json.extract! wallet_log, :id, :created_at, :display_amount, :note, :branch_name, :branch_id, :operator_name
  json.reason wallet_log.reason_name
end
