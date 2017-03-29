class CreateIndexes4cs < ActiveRecord::Migration
  def change

    add_index :ddt_vip_infos, :updated_at
    add_index :ddt_payments, :updated_at

  end
end
