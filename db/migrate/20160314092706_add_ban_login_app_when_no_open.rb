class AddBanLoginAppWhenNoOpen < ActiveRecord::Migration
  def change

    unless column_exists? :ddt_accounts, :ban_login_app_when_no_open
      add_column :ddt_accounts, :ban_login_app_when_no_open, :boolean, default: true
    end

    if column_exists? :ddt_accounts, :ban_login_app_when_off_shift
      Ddt::Account.update_all('ban_login_app_when_no_open = ban_login_app_when_off_shift')
      remove_column :ddt_accounts, :ban_login_app_when_off_shift
    else
      account_ids = Ddt::Account.boss.pluck(:id)
      Ddt::Account.where(id: account_ids).update_all(ban_login_app_when_no_open: false)
    end
  end
end
