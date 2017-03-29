class AddHoderIndexToAccessToken < ActiveRecord::Migration
  def change
    add_index :ddt_access_tokens, [:holder_type, :holder_id], name: :holder_index, :length => {:holder_type => 191}
  end
end
