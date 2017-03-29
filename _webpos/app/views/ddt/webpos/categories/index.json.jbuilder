json.cache! Digest::MD5.hexdigest(@categories.map(&:cache_key).join), expires_in: 1.day do
  json.array! @categories do |category|
    json.extract! category, :id, :name, :name_with_parent
    json.subs category.subs.each do |sub|
      json.extract! sub, :id, :name, :name_with_parent
    end
  end
end
