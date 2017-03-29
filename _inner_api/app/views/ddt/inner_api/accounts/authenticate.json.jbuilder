json.extract! @account, :id, :name, :login_id, :email, :encrypted_password, :shop_id, :built_in
json.shop_name @account.shop.try(:name)
json.shop_slug @account.shop.try(:slug)
json.roles @account.roles.map(&:name)