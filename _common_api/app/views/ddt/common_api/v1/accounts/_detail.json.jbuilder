account ||= @account
json.extract! account, :id, :name, :login_main_id, :login_sub_id, :email, :phone, :receive_email, :ban_login_app_when_no_open
if account.is_boss?
  json.manage_branches [{id: -1, name: '所有门店'}]
else
  json.manage_branches account.manage_branches.map(&:select_json)
end
json.roles account.roles.map(&:select_json)
