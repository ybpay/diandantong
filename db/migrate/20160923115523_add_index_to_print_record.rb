class AddIndexToPrintRecord < ActiveRecord::Migration
  def change
    add_index :ddt_print_records, :record_id
  end
end
