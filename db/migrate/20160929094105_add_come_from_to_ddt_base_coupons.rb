class AddComeFromToDdtBaseCoupons < ActiveRecord::Migration
  def change
    add_column :ddt_base_coupons, :track_from, :string
  end
end
