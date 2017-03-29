class RemoveForAntiSettlement < ActiveRecord::Migration
  def change
    Ddt::WalletLog.where(reason: :for_anti_settlement).update_all(reason: :for_rollback_vip_card_pay)
  end
end
