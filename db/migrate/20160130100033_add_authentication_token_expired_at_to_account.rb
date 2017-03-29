class AddAuthenticationTokenExpiredAtToAccount < ActiveRecord::Migration
  def change
    add_column :ddt_accounts, :authentication_token_expired_at, :datetime
    Ddt::Account.all.update_all(authentication_token_expired_at: Time.now)
  end
end
