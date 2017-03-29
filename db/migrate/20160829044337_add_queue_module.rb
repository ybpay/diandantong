class AddQueueModule < ActiveRecord::Migration
  def change
    Ddt::Shop.where(shop_type: 'z3').find_each do |shop|
      feature_modules_config = shop.feature_modules_configs.find_by(feature_module: 'queue')
      unless feature_modules_config.present?
        puts "start to migrate queue module for shop #{shop.slug}"
        feature_modules_config = shop.feature_modules_configs.create!(feature_module: 'queue', expired_at: shop.expiration_time)
      end
    end
  end
end
