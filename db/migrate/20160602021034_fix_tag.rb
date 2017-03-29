class FixTag < ActiveRecord::Migration
  def change
    Ddt::BranchTag.where('branch_id is not null').update_all(branch_id: nil)
    result = execute <<-SQL.strip_heredoc
      select b.id from ddt_branches as b left join ddt_branches_tags as bt on b.id = bt.branch_id where bt.branch_id is null
    SQL
    branch_ids = result.to_a.flatten
    Ddt::Branch.where(id: branch_ids).includes(:shop,:branch_type).find_each do |branch|
      if branch.branch_type.present?
        tag = branch.shop.all_tags.find_by(type: 'Ddt::BranchTag', name: branch.branch_type.name)
        if tag.present?
          branch.tags << tag
        else
          branch.tags.create!(name: branch.branch_type.name, shop_id: branch.shop_id)
        end
      end
    end
  end
end
