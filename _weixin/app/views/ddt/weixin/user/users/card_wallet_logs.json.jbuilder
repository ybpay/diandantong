
json.array! @wallet_logs do |log|
    json.extract! log, :id,:branch_name, :amount, :reason_name, :note, :operator_name, :order_id, :balance
    json.created_at log.created_at.strftime('%F %T')
end
