class FixPaymentPayMethodSetting < ActiveRecord::Migration
  def change
    count = 0
    Ddt::Shop.find_each do |shop|
      if shop.payment_pay_method_setting.blank?
        count += 1
        puts "Create payment_pay_method_setting for shop (id: #{shop.id})" if count % 100 == 0
        shop.create_payment_pay_method_setting!
      end
    end
    puts "start create payment_pay_method_setting for Branch"
    count = 0
    Ddt::Branch.find_each do |branch|
      if branch.payment_pay_method_setting.blank?
        count += 1
        puts "Create payment_pay_method_setting for branch (id: #{branch.id})" if count % 100 == 0
        branch.create_payment_pay_method_setting!
      end
    end
  end
end
