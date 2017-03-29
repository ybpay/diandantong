class FixNfcCode < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_variants, :nfc_code
      add_column :ddt_variants, :nfc_code, :integer
    end

    unless index_exists? :ddt_variants, :nfc_code
      add_index :ddt_variants, :nfc_code
    end
  end
end
