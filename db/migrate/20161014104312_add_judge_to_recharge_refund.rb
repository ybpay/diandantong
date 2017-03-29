class AddJudgeToRechargeRefund < ActiveRecord::Migration
  def change
    add_reference :ddt_recharge_refunds, :reviewer, index: true
    add_column :ddt_recharge_refunds, :review_time, :datetime
  end
end
