class FixBranchCompetitionResource < ActiveRecord::Migration
  def up
    sql = <<-SQL.strip_heredoc
      select b.id from ddt_branches as b
        left outer join ddt_competition_resources as c
        on c.owner_id = b.id and c.owner_type = "Ddt::Branch"
      where c.id is NULL;
    SQL
    branch_ids = execute(sql).to_a.flatten.uniq
    competition_resources = branch_ids.map do |branch_id|
      Ddt::CompetitionResource.new(owner_id: branch_id, owner_type: "Ddt::Branch", name: :order_number)
    end
    Ddt::CompetitionResource.import(competition_resources, validate: false)
  end

  def down

  end
end
