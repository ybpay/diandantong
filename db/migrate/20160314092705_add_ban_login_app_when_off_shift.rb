class AddBanLoginAppWhenOffShift < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_accounts, :ban_login_app_when_off_shift
      add_column :ddt_accounts, :ban_login_app_when_off_shift, :boolean, default: true
    end
    
    account_ids = Ddt::Account.boss.pluck(:id)
    Ddt::Account.where(id: account_ids).update_all(ban_login_app_when_off_shift: false)
  end
end
