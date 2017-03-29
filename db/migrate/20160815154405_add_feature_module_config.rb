class AddFeatureModuleConfig < ActiveRecord::Migration

  def change
    Ddt::ShopRechargeRecord.skip_callback(:create, :after, :group_to_feature_module_config)
    total = Ddt::Shop.count
    count = 0
    Ddt::Shop.find_each do |shop|
      
      if count % 100 == 0
        puts "finish migrate the #{count}th shop, finished #{count*100.0/total}"
      end

      Ddt::ShopRechargeRecord.transaction do 
        if shop.max_branches_limit < shop.branches.size
          puts "------------- shop #{shop.slug} max_branches_limit:#{shop.max_branches_limit} < branches_size:#{shop.branches.size}"
          shop.update_column(:max_branches_limit, shop.branches.size)
        end
      
        if [:mini, :standard, :chain, :multiple].include? shop.shop_type.to_sym
          recharge_type = "base"
          if shop.shop_type.to_sym == :mini
            recharge_type = "z1"
          elsif shop.shop_type.to_sym == :standard
            recharge_type = "z4"
          elsif shop.shop_type.to_sym == :chain
            recharge_type = "z5"
          elsif shop.shop_type.to_sym == :multiple
            recharge_type = "o3"
          end
          note = "系统新版本升级，升级前版本#{shop.shop_type}"
          shop.upgrade_shop_to(recharge_type, shop.max_branches_limit, shop.expiration_time, true)
          shop_recharge_record = shop.shop_recharge_records.where(recharge_type: recharge_type).first_or_initialize
          shop_recharge_record.increment_days = 0
          shop_recharge_record.branch_num = shop.max_branches_limit
          shop_recharge_record.price = 0
          shop_recharge_record.original_price = 0
          shop_recharge_record.note = note
          shop_recharge_record.save!
        else
          puts "shop type invalid: #{shop.shop_type}"
        end
      end

      count += 1

    end
    Ddt::ShopRechargeRecord.set_callback(:create, :after, :group_to_feature_module_config)
  end
end
