class FixMinDeliveryFee < ActiveRecord::Migration
  def change
    count = 0
    Ddt::DeliverySetting.includes(:branch).where("charge_by != 'zone'").find_each do |delivery_setting|
      count+=1
      puts "FixMinDeliveryFee, migrate delivery_setting(#{count}th) id: #{delivery_setting.id}" if count%100 == 0
      branch = delivery_setting.branch
      if branch
        if delivery_setting.charge_by == 'per_unit'
          delivery_setting.update_column(:min_delivery_fee, delivery_setting.per_unit_cost)
        else
          delivery_setting.update_column(:min_delivery_fee, branch.delivery_ranges(:reload).map(&:cost).min)
        end
      end
    end
  end
end
