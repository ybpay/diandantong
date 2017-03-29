json.extract! @wechat_share_record, :id
if @wechat_share_record.verified?
  json.extract! @wechat_share_record, :viewed_users_count, :share_type_name, :title, :desc, :link, :img_url, :created_at
  json.wechat_view_records @wechat_share_record.wechat_view_records do |wechat_view_record|
    json.extract! wechat_view_record, :id, :created_at
    json.extract! wechat_view_record.viewed_user,:nickname, :headimgurl, :sex_name
  end
end