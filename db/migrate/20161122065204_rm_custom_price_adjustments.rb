class RmCustomPriceAdjustments < ActiveRecord::Migration

  def change
    execute "DELETE FROM ddt_adjustments WHERE reason = 'enjoy_custom_price'"
  end

end
