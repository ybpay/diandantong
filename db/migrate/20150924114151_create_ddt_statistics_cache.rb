class CreateDdtStatisticsCache < ActiveRecord::Migration
  def change
    create_table :ddt_statistics_caches do |t|
      t.string :key
      t.string :state, default: :commit
      t.text :result
      t.timestamps
    end
    add_index :ddt_statistics_caches, :key
  end
end
