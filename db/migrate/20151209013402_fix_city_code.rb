class FixCityCode < ActiveRecord::Migration
  def change
    Ddt::Shop.where("address IS NULL AND city_code != '000000'").update_all(city_code: '000000')
  end
end
