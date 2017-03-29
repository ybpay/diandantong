json.array! @logs do |log|
  json.(log, :type, :created_at, :expires_at, :applied_at)
  json.name log.try(:abstract_coupon_version).try(:name)
  json.code log.try(:exchange_code).try(:code)
  json.is_expired log.expires_at<Time.now
end