class AddItemableNameToLineItem < ActiveRecord::Migration
  def up
    add_column :ddt_line_items, :itemable_name, :string unless column_exists? :ddt_line_items, :itemable_name
    count = 0
    total = Ddt::LineItem.where(itemable_name: nil).count
    line_items = {}
    Ddt::LineItem.where(itemable_name: nil).find_each do |line_item|
      line_items[line_item.id] = line_item.itemable.itemable_name
      count += 1
      if count % 5000 == 0
        puts "#{Time.now.strftime("%F %T")} total = #{total}, count = #{count}, #{(count * 100.0 / total).round(2)}%"
        sql = []
        sql << "UPDATE ddt_line_items"
        sql << "SET itemable_name = CASE id"
        line_items.each do |k, v|
          v.gsub!(/\\/, "\\\\'")
          sql << "WHEN #{k} THEN '#{v}'"
        end
        sql << "END"
        sql << "WHERE id IN (#{line_items.keys.join(',')});"
        ActiveRecord::Base.connection.execute(sql.join(" "))
        line_items = {}
      end
    end
    if line_items.present?
      puts "#{Time.now.strftime("%F %T")} total = #{total}, count = #{count}, #{(count * 100.0 / total).round(2)}%"
      sql = []
      sql << "UPDATE ddt_line_items"
      sql << "SET itemable_name = CASE id"
      line_items.each do |k, v|
        v.gsub!(/\\/, "\\\\'")
        sql << "WHEN #{k} THEN '#{v}'"
      end
      sql << "END"
      sql << "WHERE id IN (#{line_items.keys.join(',')});"
      ActiveRecord::Base.connection.execute(sql.join(" "))
    end
  end

  def down
    remove_column :ddt_line_items, :itemable_name, :string if column_exists? :ddt_line_items, :itemable_name
  end
end
