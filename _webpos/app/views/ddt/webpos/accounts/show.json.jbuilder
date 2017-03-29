json.cache! [@account, @account.shop], expires_in: 1.day do
  json.extract! @account, :id, :name, :email, :phone, :shop_id
  json.roles @account.roles.map(&:name)
  json.shop do
    if @account.shop.agent.present?
      json.domain @account.shop.agent.domain_url
    end
    json.extract! @account.shop, :id, :name, :currency, :slug, :card_key, :features, :enable_foreign
    json.abstract_branch_id @account.shop.abstract_branch.id
    json.use_shop_name_for_queue current_account.shop.use_shop_name_for_queue
    json.wechat_account_name current_account.shop.primary_wechat_account.try(:account_name)
    json.wechat_account_gonghao_open_id current_account.shop.primary_wechat_account.try(:gonghao_open_id)
    json.table_color do
    	json.extract! @account.shop.table_color, :idle_color, :opened_color, :ordered_color, :check_outing_color, :paid_color, :active_color
    end
  end
  json.branches current_account.managed_branches.valid_now.as_json(only: [:id, :name])
end


json.cache! [current_account.roles], expires_in: 1.day do
  json.permissions do
    permissions = current_account.all_permissions
    json.branch permissions[:branch]
    json.shop permissions[:shop]
  end
end
