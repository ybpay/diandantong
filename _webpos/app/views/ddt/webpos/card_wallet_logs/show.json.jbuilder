json.extract! @card_wallet_log, :id, :created_at, :display_amount, :note, :branch_name, :branch_id
json.reason @card_wallet_log.reason_name
