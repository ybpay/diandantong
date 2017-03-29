class AddSmartPosIdToDdtVariants < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_variants, :nfc_code
      add_column :ddt_variants, :nfc_code, :integer
    end
  end
end
