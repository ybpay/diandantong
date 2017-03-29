json.cache! Digest::MD5.hexdigest(@categories.map(&:cache_key).join), expires_in: 1.day do
  json.array! @categories do |category|
    json.extract! category, :id, :name, :name_with_parent, :parent_id
  end
end
