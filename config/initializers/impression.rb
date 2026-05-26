#encoding: utf-8

# Impressionist configuration for PostgreSQL
# Impression data is now stored in the primary database (no separate DB)
Impressionist.setup do |config|
  config.orm = :active_record
end
