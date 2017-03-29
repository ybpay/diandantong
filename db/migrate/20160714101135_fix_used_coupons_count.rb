class FixUsedCouponsCount < ActiveRecord::Migration
  def change
    count_sql = <<-SQL.strip_heredoc
      SELECT abstract_coupon_version_id, count(1)
      FROM ddt_base_coupons
      WHERE applied_at IS NOT NULL AND refund_at IS NULL
      GROUP BY abstract_coupon_version_id
    SQL

    count_result = execute count_sql

    if count_result.size > 0
      ids = []
      when_str = ''
      count_result.each do |pair|
        ids << pair[0]
        when_str << "WHEN #{pair[0]} THEN #{pair[1]} "
      end
      update_sql = <<-SQL.strip_heredoc
        UPDATE ddt_abstract_coupon_versions
        SET used_coupons_count = case id
        #{when_str}
        END
        WHERE id IN (#{ids.join(',')})
      SQL
      execute update_sql
    end

    
  end
end
