class AddIsLocalPrintedToTable < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_tables, :is_local_printed
      add_column :ddt_tables, :is_local_printed, :boolean, default: true
    end
  end
end
