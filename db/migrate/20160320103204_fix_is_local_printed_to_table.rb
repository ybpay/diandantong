class FixIsLocalPrintedToTable < ActiveRecord::Migration
  def up
    if column_exists? :ddt_tables, :is_local_printed
        remove_column :ddt_tables, :is_local_printed
    end
  end

  def down
    unless column_exists? :ddt_tables, :is_local_printed
        add_column :ddt_tables, :is_local_printed, :boolean, default: false
    end
  end
end
