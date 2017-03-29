class FixBranchesCount < ActiveRecord::Migration
  def change
    all_count = Ddt::BranchType.count
    puts "branch_type all_count: #{all_count}"
    index = 0
    Ddt::BranchType.all.find_each do |branch_type|
      Ddt::BranchType.reset_counters(branch_type.id, :branches)
      index += 1
      puts "branch_type index: #{index}" if index % 100 == 0
    end
  end
end
