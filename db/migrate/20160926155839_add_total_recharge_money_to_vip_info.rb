class AddTotalRechargeMoneyToVipInfo < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_vip_infos, :total_recharge_money
      add_column :ddt_vip_infos, :total_recharge_money, :decimal, precision: 10, scale: 2, default: 0.0
    end

    unless column_exists? :ddt_vip_infos, :recharge_times
      add_column :ddt_vip_infos, :recharge_times, :integer
    end

    unless  column_exists? :ddt_vip_infos, :vip_card_consume_amount
      add_column :ddt_vip_infos, :vip_card_consume_amount, :decimal, precision: 10, scale: 2, default: 0.0
    end

    Ddt::VipInfo.find_each do |vip_info|
      card_wallet_logs = vip_info.card_wallet.wallet_logs
      vip_info.update(total_recharge_money: vip_info.card_wallet.total_recharge_money, recharge_times: Ddt::Order.where(vip_info_id: vip_info.id, type: "Ddt::RechargeOrder").count, vip_card_consume_amount: - card_wallet_logs.where(reason: "for_vip_card_pay").sum(:amount))
    end

  end
end