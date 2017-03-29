class FixDeduction < ActiveRecord::Migration
  def up
    Ddt::CreditsDeduction.where(wallet_id: nil).find_each do |deduction|
      deduction.wallet = deduction.order.try(:user).try(:credits_wallet)
      deduction.save
    end

    Ddt::CardDeduction.where(wallet_id: nil).find_each do |deduction|
      deduction.wallet = deduction.order.try(:user).try(:card_wallet)
      deduction.save
    end
  end

  def down

  end
end
