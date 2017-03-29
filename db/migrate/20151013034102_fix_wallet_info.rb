class FixWalletInfo < ActiveRecord::Migration
  def up
    error_wallets = []
    Ddt::WalletLog.user_card.where(reason: :for_import).where("ddt_wallet_logs.created_at > '2015-08-06 00:00:00'").find_each do |wallet_log|
      wallet = wallet_log.wallet
      if (wallet.amount - wallet.cash_amount - wallet.extra_amount).abs > 0.0001
        puts "start to migrate for wallet #{wallet.id} and wallet_log #{wallet_log.id}"
        wallet.cash_amount += wallet_log.amount
        wallet.save!
        if wallet.cash_amount + wallet.extra_amount != wallet.amount
          error_wallets << wallet
          puts "wallet #{wallet.id}: #{wallet.cash_amount} + #{wallet.extra_amount} != #{wallet.amount}"
        end
      else
        puts "=====================================wallet #{wallet.id} of import wallet log #{wallet_log.id} do not need migrate as the wallet is normal"
      end
    end
    puts error_wallets.map(&:id).join(",")
  end

  def down
  end
end
