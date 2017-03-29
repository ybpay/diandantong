class AddPricesToComboPackageItem < ActiveRecord::Migration
  def change

    unless column_exists? :ddt_combo_package_items, :price
      add_column :ddt_combo_package_items, :price, :decimal, precision: 8, scale: 2, default: 0.0
      add_column :ddt_combo_package_items, :vip_price, :decimal, precision: 8, scale: 2, default: 0.0
      add_column :ddt_combo_package_items, :original_price, :decimal, precision: 8, scale: 2, default: 0.0
    end

    n = 0
    Ddt::ComboPackage.includes(:combo_package_items).where("ddt_combo_package_items.price = 0.0").references(:ddt_combo_package_items).find_each do |combo_package|
      Ddt::ComboPackageItem.set_prices(combo_package.combo_package_items)
      n += 1
      puts "AddComboPackageItemPrice: #{n}th, id: #{combo_package.id}" if n%100 == 0
    end
  end
end
