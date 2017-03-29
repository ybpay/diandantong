class CreateDdtPayMethodsPromotionRules < ActiveRecord::Migration
  def change
    create_table :ddt_pay_methods_promotion_rules, id: false do |t|
      t.integer :pay_method_id
      t.integer :promotion_rule_id
    end
    add_index :ddt_pay_methods_promotion_rules, :pay_method_id, name: 'fk_dpmpr_pay_method_id'
    add_index :ddt_pay_methods_promotion_rules, :promotion_rule_id, name: 'fk_dpmpr_promotion_rule_id'
  end
end
