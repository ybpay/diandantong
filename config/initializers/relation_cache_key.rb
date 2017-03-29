require "digest/md5"

# 需要手动调用
# json.cache! table_zone.tables.cache_key, expires_in: 1.day do

module RelationCacheKey
  def cache_key
    model_identifier = name.underscore.pluralize
    relation_identifier = Digest::MD5.hexdigest(to_sql.downcase)
    max_updated_at = maximum(:updated_at).try(:utc).try(:to_s, :number)

    "#{model_identifier}/#{relation_identifier}-#{count}-#{max_updated_at}"
  end
end

ActiveRecord::Relation.send :include, RelationCacheKey