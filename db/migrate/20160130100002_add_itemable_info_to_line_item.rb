class AddItemableInfoToLineItem < ActiveRecord::Migration
  def up
    unless column_exists? :ddt_line_items, :unit_name
      sql = ActiveRecord::Base.connection()
      sql.execute "SET autocommit=0"
      sql.begin_db_transaction
      sql.execute("CREATE TABLE ddt_line_items_new LIKE ddt_line_items")
      add_column :ddt_line_items_new, :unit_name, :string
      add_column :ddt_line_items_new, :vip_price, :decimal, precision: 8, scale: 2
      add_column :ddt_line_items_new, :category_names, :string
      add_column :ddt_line_items_new, :enable_discount, :boolean
      add_column :ddt_line_items_new, :order_change_log_id, :integer
      add_column :ddt_line_items_new, :is_subtract, :boolean, default: false
      add_column :ddt_line_items_new, :source_line_item_id, :integer
      add_column :ddt_line_items_new, :subtract_quantity, :integer, default: 0
      add_column :ddt_line_items_new, :subtract_reason, :string
      add_column :ddt_line_items_new, :product_name, :string
      sql.execute <<-SQL
        INSERT INTO ddt_line_items_new
          SELECT *,
            NULL, NULL, NULL, NULL, NULL, 0, NULL, 0, NULL, NULL
          FROM ddt_line_items
      SQL
      rename_table :ddt_line_items, :ddt_line_items_old
      rename_table :ddt_line_items_new, :ddt_line_items
      sql.commit_db_transaction
      sql.execute "SET autocommit=1"
    end
    # count = 0
    # total = Ddt::LineItem.where(unit_name: nil).count
    # line_items = {}
    # Ddt::LineItem.where(unit_name: nil).find_each do |line_item|
    #   unit_name = (line_item.itemable.unit_name rescue "份")
    #   vip_price = (line_item.itemable.vip_price.to_f rescue line_item.price)
    #   category_names = (line_item.itemable_type == "Ddt::Variant" ? (line_item.itemable.categories.map(&:name).join(",") rescue nil) : nil)
    #   enable_discount = (line_item.itemable.enable_discount? ? 1 : 0 rescue 0)
    #   line_items[line_item.id] = [unit_name, vip_price, category_names, enable_discount]
    #   count += 1
    #   if count % 500 == 0
    #     update_line_items(line_items, total, count)
    #     line_items = {}
    #   end
    # end
    # update_line_items(line_items, total, count)

    add_column :ddt_products, :cache_category_names, :string unless column_exists? :ddt_products, :cache_category_names

    execute <<-SQL.strip_heredoc
      update ddt_products p
        set cache_category_names = (
          select GROUP_CONCAT(c.name SEPARATOR ' ')
            from ddt_categories c
            left join ddt_categories_products cp on c.id = cp.category_id
            where cp.product_id = p.id
        );
    SQL

    # variant
    execute <<-SQL.strip_heredoc
      update ddt_line_items l
        left join ddt_variants v on v.id = l.itemable_id
        left join ddt_products p on p.id = v.product_id
        set
          l.unit_name = p.unit_name,
          l.vip_price = v.vip_price,
          l.category_names = p.cache_category_names,
          l.enable_discount = p.enable_discount
        where l.itemable_type = 'Ddt::Variant';
    SQL
    # combo_package
    execute <<-SQL.strip_heredoc
      update ddt_line_items l
        left join ddt_combo_packages cp on cp.id = l.itemable_id
        left join ddt_combos c on c.id = cp.combo_id
        set
          l.unit_name = c.unit_name,
          l.vip_price = l.price,
          l.category_names = '',
          l.enable_discount = c.enable_discount
        where l.itemable_type = 'Ddt::ComboPackage';
    SQL
    # variant_package
    execute <<-SQL.strip_heredoc
      update ddt_line_items l
        left join ddt_variant_packages vp on vp.id = l.itemable_id
        left join ddt_variants v on v.id = vp.variant_id
        left join ddt_products p on p.id = v.product_id
        set
          l.unit_name = p.unit_name,
          l.vip_price = v.vip_price * vp.weight,
          l.category_names = p.cache_category_names,
          l.enable_discount = p.enable_discount
        where l.itemable_type = 'Ddt::VariantPackage';
    SQL
    # AbstractCouponVersion
    execute <<-SQL.strip_heredoc
      update ddt_line_items
        set
          unit_name = '张',
          vip_price = price,
          category_names = '',
          enable_discount = 0
        where itemable_type in (
          'Ddt::AbstractCouponVersion',
          'Ddt::GrouponVersion',
          'Ddt::VoucherVersion');
    SQL
    # recharge_product
    execute <<-SQL.strip_heredoc
      update ddt_line_items
        set
          unit_name = '',
          vip_price = price,
          category_names = '',
          enable_discount = 0
        where itemable_type = 'Ddt::RechargeProduct';
    SQL
  end

  def down
    drop_table :ddt_line_items
    rename_table :ddt_line_items_old, :ddt_line_items
  end

  private
  def update_line_items(line_items, total_count, current_count)
    if line_items.present?
      puts "#{Time.now.strftime("%F %T")} total = #{total_count}, count = #{current_count}, #{(current_count * 100.0 / total_count).round(2)}%"
      sql = []
      sql << "UPDATE `ddt_line_items`"
      sql << "SET `ddt_line_items`.`unit_name` = CASE `ddt_line_items`.`id`"
      line_items.each do |k, v|
        v[0].gsub!(/\"/, "\'")
        sql << "WHEN #{k} THEN \"#{v[0]}\""
      end
      sql << "END,"
      sql << "`ddt_line_items`.`vip_price` = CASE `ddt_line_items`.`id`"
      line_items.each do |k, v|
        sql << "WHEN #{k} THEN #{v[1]}"
      end
      sql << "END,"
      sql << "`ddt_line_items`.`category_names` = CASE `ddt_line_items`.`id`"
      line_items.each do |k, v|
        if v[2].present?
          v[2].gsub!(/\"/, "\'")
          sql << "WHEN #{k} THEN \"#{v[2]}\""
        else
          sql << "WHEN #{k} THEN ''"
        end
      end
      sql << "END,"
      sql << "`ddt_line_items`.`enable_discount` = CASE `ddt_line_items`.`id`"
        line_items.each do |k, v|
          sql << "WHEN #{k} THEN #{v[3]}"
        end
      sql << "END"
      sql << "WHERE `ddt_line_items`.`id` IN (#{line_items.keys.join(',')});"
      ActiveRecord::Base.connection.execute(sql.join(" "))
    end
  end
end
