class FixImpressionIndex < ActiveRecord::Migration
  def change
  	remove_index :impressions, :name => "impression_date_index"
		remove_index :impressions, :name => "poly_ip_index"
  	remove_index :impressions, :name => "impression_index"
  	remove_index :impressions, :name => "poly_request_index"
  	remove_index :impressions, :name => "poly_session_index"
  	add_index "impressions", ["impressionable_type", "impressionable_id", "created_at", "ip_address"], :name => "poly_ip_index"
  	add_index "impressions", ["impressionable_type", "impressionable_id", "created_at", "request_hash"], :name => "poly_request_index"
  	add_index "impressions", ["impressionable_type", "impressionable_id", "created_at", "session_hash"], :name => "poly_session_index"

  end
end
