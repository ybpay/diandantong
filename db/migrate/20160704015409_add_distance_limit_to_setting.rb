class AddDistanceLimitToSetting < ActiveRecord::Migration
  def up
    add_column :ddt_eat_in_hall_settings, :confirm_type, :string, default: "confirm_auto" # [:confirm_auto, :confirm_by_distance, :confirm_manual]
    sql = <<-SQL
      update ddt_eat_in_hall_settings s
        inner join ddt_branches as b on b.id = s.branch_id
      set
        s.confirm_type =
          case b.is_auto_confirm
            when 1 then "confirm_auto"
            when 0 then "confirm_manual"
          end;
    SQL
    execute(sql)
  end

  def down
    remove_column :ddt_eat_in_hall_settings, :confirm_type, :string, default: "confirm_auto"
  end
end
