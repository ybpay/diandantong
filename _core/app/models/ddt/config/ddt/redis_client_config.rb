#encoding:utf-8
class Ddt::RedisClientConfig < Settingslogic
  source "#{Rails.root}/config/redis_client.yml"
  namespace Rails.env
end