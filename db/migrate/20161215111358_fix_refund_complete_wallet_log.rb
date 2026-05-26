class FixRefundCompleteWalletLog < ActiveRecord::Migration
  def change
    Ddt::RechargeRefund.where(state: 'completed').find_each do |recharge_refund|
      create_complete_wallet_log(recharge_refund)
    end
  end

  def create_complete_wallet_log(r)
    if r.vip_info.present? and r.vip_info.card_wallet.present? and r.vip_info.credits_wallet.present?
      if r.vip_info.card_wallet.wallet_logs.find_by(reason: :for_recharge_refund_complete, order_id: r.order_id).blank?
        puts "fix card_wallet --> #{r.id} b: #{r.branch_id} o: #{r.order_id}"
        r.vip_info.card_wallet.complete_recharge_refund(r.amount, r.cash_amount, r.extra_amount, r.order)
      end
      if r.credits > 0 && r.vip_info.credits_wallet.wallet_logs.find_by(reason: :for_recharge_refund_complete, order_id: r.order_id).blank?
        puts "fix credits_wallet --> #{r.id} b: #{r.branch_id} o: #{r.order_id}"
        r.vip_info.credits_wallet.complete_recharge_refund(r.credits, r.order) if r.credits > 0
      end
    end
  end

end