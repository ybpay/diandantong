class CreateApplyLog < ActiveRecord::Migration
  def change
    create_table :ddt_apply_logs do |t|
      t.references :shop, index: true
      t.references :wechat_account, index: true
      t.integer :apply_id
      t.string :apply_reason
      t.datetime :apply_time
      t.integer :quantity
      t.integer :poi_id
      t.string :comment
      t.integer :audit_status
      t.string :audit_comment
      t.datetime :audit_time
      t.timestamps
    end
  end
end
