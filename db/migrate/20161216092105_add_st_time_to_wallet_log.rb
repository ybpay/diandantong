class AddStTimeToWalletLog < ActiveRecord::Migration
  def change
    if !column_exists? :ddt_wallet_logs, :st_time
      add_column :ddt_wallet_logs, :st_time, :datetime
    end
    execute <<-SQL
      UPDATE ddt_wallet_logs
      SET st_time = created_at
    SQL

    [
      [:for_deduction_complete, :for_deduction],
      [:for_deduction_cancel, :for_deduction],
      [:for_rollback_vip_card_pay, :for_vip_card_pay],
      [:for_recharge_refund_complete, :for_recharge],
      [:for_recharge_refund_cancel, :for_recharge]
    ].each do |pair|
      execute <<-SQL
        UPDATE ddt_wallet_logs as a
        INNER JOIN ddt_wallet_logs as b ON a.wallet_id = b.wallet_id AND a.order_id = b.order_id
        SET a.st_time = b.created_at
        WHERE a.reason = '#{pair[0]}'
        AND b.reason = '#{pair[1]}'
      SQL
    end

    # 积分
    [
      [:for_recharge_refund_complete, :for_grant],
      [:for_recharge_refund_cancel, :for_grant]
    ].each do |pair|
      execute <<-SQL
        UPDATE ddt_wallet_logs as a
        INNER JOIN ddt_wallet_logs as b ON a.wallet_id = b.wallet_id AND a.order_id = b.order_id
        SET a.st_time = b.created_at
        WHERE a.reason = '#{pair[0]}'
        AND b.reason = '#{pair[1]}'
        AND b.note = '充值赠送'
      SQL
    end

  end
end
