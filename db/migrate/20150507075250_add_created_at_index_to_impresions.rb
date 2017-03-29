class AddCreatedAtIndexToImpresions < ActiveRecord::Migration
  def change
  	add_index :impressions, :created_at
  end
end
