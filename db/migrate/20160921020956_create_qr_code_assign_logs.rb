class CreateQrCodeAssignLogs < ActiveRecord::Migration
  def change
    create_table :ddt_qr_code_assign_logs do |t|
      t.integer :count
      t.integer :branch_id
      t.integer :shop_id
      t.timestamps
    end
  end
end
