class AddDistanceToShakeInfos < ActiveRecord::Migration
  def change
    unless column_exists? :ddt_shake_infos, :distance
      add_column :ddt_shake_infos, :distance, :decimal, precision: 8, scale: 2
    end
  end
end
