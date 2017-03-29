json.cache! @tick_accounts.cache_key, expires_in: 1.day do
  json.array! @tick_accounts do |tick_account|
    json.(tick_account, :id, :name, :note)
  end
end
