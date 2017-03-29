class FixComboItemOriginalPrice < ActiveRecord::Migration
  def change
    Ddt::ComboItem.where('original_price = 0').update_all('original_price = price')
  end
end
