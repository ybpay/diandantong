class FixWalletAmount < ActiveRecord::Migration
  def change
    transaction do
      Ddt::WalletLog.branch_card.where(reason: :for_clearing).each do |wallet_log|
        if wallet_log.amount != wallet_log.cash_amount + wallet_log.extra_amount
          wallet_log.cash_amount = -wallet_log.cash_amount
          wallet_log.extra_amount = -wallet_log.extra_amount
          wallet_log.amount = wallet_log.cash_amount + wallet_log.extra_amount
          wallet_log.save
        end
      end
      Ddt::WalletLog.card.where("ddt_wallet_logs.amount <> ddt_wallet_logs.cash_amount + ddt_wallet_logs.extra_amount").where(reason: :for_vip_card_pay).each do |log|
        if log.extra_amount > 0
          log.decrement!(:extra_amount, 0.01)
          log.wallet.decrement!(:extra_amount, 0.01)
        else
          log.increment!(:extra_amount, 0.01)
          log.wallet.increment!(:extra_amount, 0.01)
        end
      end
    end
  end
end
