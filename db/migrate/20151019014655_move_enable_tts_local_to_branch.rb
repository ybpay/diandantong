class MoveEnableTtsLocalToBranch < ActiveRecord::Migration
  def up
    unless column_exists? :ddt_branches, :enable_tts_local
      add_column :ddt_branches, :enable_tts_local, :boolean, default: false
    end
    
    if column_exists? :ddt_arranging_settings, :enable_tts_local
      execute <<-SQL
        UPDATE ddt_branches b
        JOIN ddt_arranging_settings a ON b.id = a.branch_id
        SET b.enable_tts_local = a.enable_tts_local;
      SQL
      remove_column :ddt_arranging_settings, :enable_tts_local, :boolean
    end
    branch_ids = []
    Ddt::Shop.all.find_each do |shop|
      if shop.branches.any?
        if shop.shop_type == 'chain'
          branch_ids << shop.branches.map(&:id)
        else
          branch_ids << shop.branches.first.id
        end
      end
    end
    Ddt::Branch.where(id: branch_ids.flatten).update_all(enable_tts_local: true)
  end

  def down
    add_column :ddt_arranging_settings, :enable_tts_local, :boolean
    remove_column :ddt_branches, :enable_tts_local, :boolean
  end
end
