json.extract! shop, :id, :name, :slug, :phone, :enable_foreign, :service_email, :max_branches_limit, :shop_type_name, :shop_type, :agent_no
json.expiration_time shop.expiration_time.strftime("%F %T")
json.created_at shop.created_at.strftime("%F %T")
json.account do 
  if shop.primary_boss_account.present?
    json.extract! shop.primary_boss_account, :id, :name, :email, :login_id
  end
end
json.primary_wechat_account do 
  if shop.primary_wechat_account.present?
    json.extract! shop.primary_wechat_account, :id, :gonghao_open_id, :public_account_name
    json.url "http://open.weixin.qq.com/qr/code/?username=#{shop.primary_wechat_account.gonghao_open_id}"
  end
end
json.shop_recharge_records do 
  json.array! shop.shop_recharge_records do |record|
    json.extract! record, :id, :recharge_type_name, :price, :branch_num, :increment_days, :note
    json.created_at record.created_at.strftime("%F %T")
    json.beginning_time record.beginning_time.strftime("%F %T")
    json.ending_time record.ending_time.strftime("%F %T")
  end
end