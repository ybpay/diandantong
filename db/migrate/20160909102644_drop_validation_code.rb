class DropValidationCode < ActiveRecord::Migration
  def change
    drop_table :ddt_validation_codes
  end
end
