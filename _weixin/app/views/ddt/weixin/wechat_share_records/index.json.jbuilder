json.array! @wechat_share_records do |wechat_share_record|
  json.extract! wechat_share_record, :id, :title, :share_type_name, :desc, :created_at, :img_url, :viewed_users_count
end