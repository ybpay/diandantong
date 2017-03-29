json.(@shop, :id, :name, :slug, :features)
json.account do
  json.(current_account, :id, :name)
end