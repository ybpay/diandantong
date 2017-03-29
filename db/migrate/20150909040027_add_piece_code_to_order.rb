class AddPieceCodeToOrder < ActiveRecord::Migration
  def change
    add_column :ddt_orders, :piece_code, :string
    add_column :ddt_orders, :updated_piece_code_at, :datetime
  end
end
