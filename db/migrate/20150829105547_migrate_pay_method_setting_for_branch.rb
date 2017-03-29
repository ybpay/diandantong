class MigratePayMethodSettingForBranch < ActiveRecord::Migration
  def change
    count = 0
    Ddt::Branch.find_each do |branch|
      puts "migrate paymethod setting for branch #{count}th branch_id: #{branch.id}" if count % 100 == 0
      branch.create_fastfood_pay_method_setting!
      count+=1
    end
  end
end
