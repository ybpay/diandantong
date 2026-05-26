class FixImpressionIndex < ActiveRecord::Migration
  def change
  	remove_index :impressions, :name => "impression_date_index"
		remove_index :impressions, :name => "poly_ip_index"
  	remove_index :impressions, :name => "impression_index"
  	remove_index :impressions, :name => "poly_request_index"
  	remove_index :impressions, :name => "poly_session_index"
  	add_index "impressions", ["impressionable_type", "impressionable_id", "created_at", "ip_address"], :name => "poly_ip_index", length: {"impressionable_type"=>50, "impressionable_id"=>nil, "created_at" => nil,"ip_address"=>191}
  	add_index "impressions", ["impressionable_type", "impressionable_id", "created_at", "request_hash"], :name => "poly_request_index", length: {"impressionable_type"=>50, "impressionable_id"=>nil, "created_at" => nil,"request_hash"=>191}
  	add_index "impressions", ["impressionable_type", "impressionable_id", "created_at", "session_hash"], :name => "poly_session_index", length: {"impressionable_type"=>50, "impressionable_id"=>nil, "created_at" => nil,"session_hash"=>191}

  end
end
