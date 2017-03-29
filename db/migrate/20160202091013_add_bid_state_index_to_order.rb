class AddBidStateIndexToOrder < ActiveRecord::Migration
  def change
  	unless index_name_exists? :ddt_orders, :index_on_bid_and_state, false
  		add_index :ddt_orders, [:branch_id, :state], :name => "index_on_bid_and_state"
  	end
  end
end
