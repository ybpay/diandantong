#encoding: utf-8
module Ddt
  module Schedule
    class CheckWalletAmountWorker < Ddt::Schedule::Base
      def perform
        if is_production?
          error_card_wallet_log_ids = Ddt::WalletLog.card.where("ddt_wallet_logs.amount <> ddt_wallet_logs.cash_amount + ddt_wallet_logs.extra_amount").pluck(:id)
          error_user_card_wallet_ids = []
          index = 0
          count = Ddt::UserCardWallet.count
          puts "all user card wallet count : #{count}"
          Ddt::UserCardWallet.all.find_each do |wallet|
            unless wallet.check_amount_correct?
              error_user_card_wallet_ids << wallet.id
            end
            puts index if index % 1000 == 0
            index += 1
          end
          error_branch_card_wallet_ids = []
          index = 0
          count = Ddt::BranchCardWallet.count
          puts "all branch card wallet count : #{count}"
          Ddt::BranchCardWallet.all.find_each do |wallet|
            unless wallet.check_amount_correct?
              error_branch_card_wallet_ids << wallet.id
            end
            puts index if index % 1000 == 0
            index += 1
          end
          error_shop_card_wallet_ids = []
          index = 0
          count = Ddt::ShopCardWallet.count
          puts "all shop card wallet count : #{count}"
          Ddt::ShopCardWallet.all.find_each do |wallet|
            unless wallet.check_amount_correct?
              error_shop_card_wallet_ids << wallet.id
            end
            puts index if index % 1000 == 0
            index += 1
          end
          error_user_credits_wallet_ids = []
          index = 0
          count = Ddt::UserCreditsWallet.count
          puts "all user credits wallet count : #{count}"
          Ddt::UserCreditsWallet.all.find_each do |wallet|
            unless wallet.check_amount_correct?
              error_user_credits_wallet_ids << wallet.id
            end
            puts index if index % 1000 == 0
            index += 1
          end
          error_branch_credits_wallet_ids = []
          index = 0
          count = Ddt::BranchCreditsWallet.count
          puts "all branch credits wallet count : #{count}"
          Ddt::BranchCreditsWallet.all.find_each do |wallet|
            unless wallet.check_amount_correct?
              error_branch_credits_wallet_ids << wallet.id
            end
            puts index if index % 1000 == 0
            index += 1
          end
          error_shop_credits_wallet_ids = []
          index = 0
          count = Ddt::ShopCreditsWallet.count
          puts "all shop credits wallet count : #{count}"
          Ddt::ShopCreditsWallet.all.find_each do |wallet|
            unless wallet.check_amount_correct?
              error_shop_credits_wallet_ids << wallet.id
            end
            puts index if index % 1000 == 0
            index += 1
          end
          BaseMailer.notify(
            Rails.application.config.dev_mail_group,
            "[会员卡余额校验]",
            [
              "error_card_wallet_log_ids: (#{error_card_wallet_log_ids.size}) #{error_card_wallet_log_ids.join(",")}",
              "error_user_card_wallet_ids: (#{error_user_card_wallet_ids.size}) #{error_user_card_wallet_ids.join(",")}",
              "error_branch_card_wallet_ids: (#{error_branch_card_wallet_ids.size}) #{error_branch_card_wallet_ids.join(",")}",
              "error_shop_card_wallet_ids: (#{error_shop_card_wallet_ids.size}) #{error_shop_card_wallet_ids.join(",")}",
              "error_user_credits_wallet_ids: (#{error_user_credits_wallet_ids.size}) #{error_user_credits_wallet_ids.join(",")}",
              "error_branch_credits_wallet_ids: (#{error_branch_credits_wallet_ids.size}) #{error_branch_credits_wallet_ids.join(",")}",
              "error_shop_credits_wallet_ids: (#{error_shop_credits_wallet_ids.size}) #{error_shop_card_wallet_ids.join(",")}",
            ].join("\n")
          )
        end
      end
    end
  end
end
