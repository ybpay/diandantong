class AddIndexToImpression < ActiveRecord::Migration
  def change
  	add_index "impressions", ["impressionable_type", "impressionable_id"], name: "impression_index", length: {"impressionable_type"=>191, "impressionable_id"=>nil}
  end
end
