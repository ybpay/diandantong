class MigrateRechargeWalletLog < ActiveRecord::Migration
  def change
    execute <<-SQL
      UPDATE ddt_wallet_logs log
      LEFT JOIN ddt_pay_methods pay_method ON log.shop_id = pay_method.shop_id
      SET 
        log.pay_method_id = pay_method.id,
        log.pay_method_name = '现金支付'
      WHERE log.reason='for_recharge' AND pay_method.name_sym = 'pay_on_face';
    SQL
  end
end
