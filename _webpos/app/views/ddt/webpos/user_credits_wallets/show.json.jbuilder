json.credits_wallet do
  json.extract! @wallet, :id, :amount, :display_amount
end