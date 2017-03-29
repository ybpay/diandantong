class AddNoteToShipment < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_shipments, :note
      add_column :ddt_shipments, :note, :string
    end
  end
end
