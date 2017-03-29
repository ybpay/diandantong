class FixOriginalPrice < ActiveRecord::Migration
  def change
    Ddt::ComboItemsVariant.find_each do |i|
      i.send :set_prices
      i.save
    end
  end
end
