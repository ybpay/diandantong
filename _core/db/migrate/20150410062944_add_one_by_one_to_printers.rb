class AddOneByOneToPrinters < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_printers, :print_one_by_one
      add_column :ddt_printers, :print_one_by_one, :boolean, default: false
    end
  end
end
