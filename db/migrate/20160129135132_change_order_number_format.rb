class ChangeOrderNumberFormat < ActiveRecord::Migration
  def up
    unless column_exists? :ddt_orders, :old_number
      add_column :ddt_orders, :old_number, :string
    end
    execute <<-SQL.strip_heredoc
      update ddt_orders set old_number = number;
    SQL
    branch_ids = Ddt::Branch.all.pluck(:id)
    competition_resources = branch_ids.map do |branch_id|
      Ddt::CompetitionResource.new(owner_id: branch_id, owner_type: "Ddt::Branch", name: :order_number)
    end
    Ddt::CompetitionResource.import(competition_resources, validate: false)
    if index_exists? :ddt_orders, :number
      remove_index :ddt_orders, :number
    end
    execute <<-SQL.strip_heredoc
      update ddt_orders set number = CONCAT(CAST(branch_id as CHAR(10)), SUBSTRING(number, -12)) where number is not null;
    SQL

    unless index_exists? :ddt_orders, :number
      add_index :ddt_orders, :number, :unique => true, :using => :btree, :length=>{:number => 191}
    end
  end

  def down
  end
end
