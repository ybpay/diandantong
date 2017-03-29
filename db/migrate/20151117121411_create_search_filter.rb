class CreateSearchFilter < ActiveRecord::Migration
  def change
    create_table :ddt_search_filters do |t|
      t.references :shop
      t.references :branch
      t.string :name
      t.string :model_type
      t.string :match_policy
      t.string :ransack_q
      t.string :state, default: :init
      t.timestamps
    end

    create_table :ddt_search_results do |t|
      t.references :shop
      t.references :branch
      t.references :search_filter
      t.integer :count
      t.timestamps
    end

    create_table :ddt_search_details do |t|
      t.references :search_result
      t.integer :model_id
    end
  end
end
