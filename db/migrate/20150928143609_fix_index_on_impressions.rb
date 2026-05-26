class FixIndexOnImpressions < ActiveRecord::Migration
  def change
  	add_index "impressions", ["impressionable_type", "impressionable_id", "created_at"], name: "impression_date_index"
  end
end
