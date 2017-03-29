class MigrateOperatorName < ActiveRecord::Migration
  def change
    n = 0
    Ddt::Shop.find_each do |shop|
      names = shop.accounts.with_deleted.pluck(:id, :name)
      names = Hash[names]
      names.each do |id, name|
        Ddt::OrderChangeLog.where(shop_id: shop.id, operator_type: 'Ddt::Account', operator_id: id)
          .update_all(operator_name: "工作人员: #{name}")
      end
      n += 1
      puts "#{n}th, shop_id: #{shop.id}" if n%100 == 0
    end
    Ddt::OrderChangeLog.where(operator_type: 'Ddt::BaseUser').update_all("operator_name=CONCAT('客人编号: ', operator_id)")
  end
end
