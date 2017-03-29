class AddPrintSpecToPrinters < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_printers, :print_spec
      add_column :ddt_printers, :print_spec, :string, default: '58'
    end
  end
end
