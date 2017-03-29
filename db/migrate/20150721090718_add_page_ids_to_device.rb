class AddPageIdsToDevice < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_devices, :page_ids
      add_column :ddt_devices, :page_ids, :string
    end
  end
end
