class AddLevelToVipLevel < ActiveRecord::Migration
  def change
    if !column_exists? :ddt_vip_levels, :level
      add_column :ddt_vip_levels, :level, :integer, default: 0
    end

    # PostgreSQL equivalent: use a subquery with row_number() to assign levels
    # per shop_id, ordered by discount desc, id asc.
    # Default level gets 0, non-default levels get sequential numbers starting at 1.
    execute <<-SQL
      WITH ranked AS (
        SELECT id,
               CASE WHEN is_default THEN 0
                    ELSE ROW_NUMBER() OVER (
                      PARTITION BY shop_id
                      ORDER BY discount DESC, id ASC
                    ) - SUM(CASE WHEN is_default THEN 1 ELSE 0 END) OVER (
                      PARTITION BY shop_id
                      ORDER BY discount DESC, id ASC
                    )
               END AS new_level
        FROM ddt_vip_levels
      )
      UPDATE ddt_vip_levels
      SET level = ranked.new_level
      FROM ranked
      WHERE ddt_vip_levels.id = ranked.id;
    SQL

=begin
    if is_default
      if pre_shop_id != shop_id
        pre_shop_id = shop_id
        pre_level = 0
        0
      else
        0
      end
    else
      if pre_shop_id != shop_id
        pre_shop_id = shop_id
        pre_level = 1
      else
        pre_level = pre_level + 1
      end
    end
=end
  end
end
