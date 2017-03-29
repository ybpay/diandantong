class FixIndexOnImpressions < ActiveRecord::Migration
  def change
  	add_index "impressions", ["impressionable_type", "impressionable_id", "created_at"], name: "impression_date_index",length: {"impressionable_type"=>191, "impressionable_id"=>nil, "created_at"=>nil}
  end
end
