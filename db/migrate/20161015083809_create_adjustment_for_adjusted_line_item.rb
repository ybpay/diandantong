class CreateAdjustmentForAdjustedLineItem < ActiveRecord::Migration
  VERSION = "20161015083809"
  def change
    handle_rerun
    create_first_adjustment
    create_another_adjustment
    update_order_adjustment_total
  end

  def handle_rerun
    if !column_exists? :ddt_adjustments, :migrate_flag
      add_column :ddt_adjustments, :migrate_flag, :string
    end
    execute "DELETE FROM ddt_adjustments where migrate_flag = '#{version}_part2_3'"
    execute "DELETE FROM ddt_adjustments where migrate_flag = '#{version}_part2_2'"
    execute "DELETE FROM ddt_adjustments where migrate_flag = '#{version}_part2_1'"
    execute "DELETE FROM ddt_adjustments where migrate_flag = '#{version}_part1_3'"
    execute "DELETE FROM ddt_adjustments where migrate_flag = '#{version}_part1_2'"
    execute "DELETE FROM ddt_adjustments where migrate_flag = '#{version}_part1_1'"
  end

  def create_first_adjustment
    params_array = [
      {deleted_at: nil, is_subtract: false, is_moved: false, enjoy_vip_price: true},
      {deleted_at: nil, is_subtract: false, is_moved: false, enjoy_custom_price: true},
      {deleted_at: nil, is_subtract: false, is_moved: false, gift: true}
    ]

    adjust_confs = [
      {flag: "#{VERSION}_part1_1", reason: :child_enjoy_vip_price, label_format: "会员价(%s:%s)"},
      {flag: "#{VERSION}_part1_2", reason: :enjoy_custom_price, label_format: "商家改价(%s:%s)"},
      {flag: "#{VERSION}_part1_3", reason: :enjoy_gift_price, label_format: "赠菜(%s:%s)"}
    ]


    select_column = "id, id as line_item_id, itemable_name, shop_id, branch_id, order_id, price_bak - price as diff_price, quantity - subtract_quantity - move_quantity as active_quantity, gift, enjoy_vip_price, enjoy_custom_price"

    params_array.each_with_index do |params, idx|
      adjust_conf = adjust_confs[idx]
      puts '*' * 280
      puts "=> #{adjust_conf[:flag]}"
      puts '*' * 280
      count = Ddt::LineItem.where(params).where('quantity - subtract_quantity - move_quantity > 0').count
      Ddt::LineItem.select(select_column).where(params).where('quantity - subtract_quantity - move_quantity > 0').where('price_bak is not null') # price_bak 为空说明是 迁移期间产生的数据
      .find_each.with_index do |line_item, index|
        puts "=========#{line_item.id}====#{index}/#{count}" if index % 100 == 0
        create_adjustment_from_line_item(line_item, adjust_conf)
      end
    end
    import_the_rest
  end

  def create_another_adjustment
    create_gift_or_custom_price_adjustment
    create_another_vip_price_adjustment
  end

  def create_adjustment_from_line_item(line_item, adjust_conf)
    @current_time ||= Time.now
    @fixed_line_item_ids ||= []
    @order_ids ||= []
    @package ||= []
    return if @fixed_line_item_ids.include?(line_item.id)
    @fixed_line_item_ids << line_item.id
    @order_ids << line_item.order_id
    attrs = line_item.slice(:shop_id, :branch_id, :order_id, :line_item_id)
    attrs[:amount] = line_item.diff_price * line_item.active_quantity
    attrs[:reason] = adjust_conf[:reason]
    attrs[:label]  = adjust_conf[:label_format] % [line_item.itemable_name, line_item.diff_price]
    attrs[:created_at] = @current_time
    attrs[:updated_at] = @current_time
    attrs[:migrate_flag] = adjust_conf[:flag]
    @package << Ddt::Adjustment.new(attrs)
    if @package.size % 200 == 0
      Ddt::Adjustment.import(@package)
      @package = []
    end
  end

  def import_the_rest
    if @package.present?
      Ddt::Adjustment.import(@package)
      @package = []
    end
  end

  def create_gift_or_custom_price_adjustment
    flag = "'#{VERSION}_part2_1'"
    puts '*' * 280
    puts "=> #{flag}"
    puts '*' * 280
    execute <<-SQL
      INSERT INTO ddt_adjustments (migrate_flag, parent_id, reason, shop_id, branch_id, order_id, label, amount, created_at, updated_at, line_item_id)
      SELECT
        #{flag}, id, reason, shop_id, branch_id, order_id, label, amount, created_at, updated_at, line_item_id
      FROM ddt_adjustments where reason in ('enjoy_gift_price', 'enjoy_custom_price')
    SQL
  end

  def create_another_vip_price_adjustment
    flag = "'#{VERSION}_part2_2'"
    puts '*' * 280
    puts "=> #{flag}"
    puts '*' * 280
    execute <<-SQL
      INSERT INTO ddt_adjustments (migrate_flag, reason, shop_id, branch_id, order_id, amount, created_at, updated_at)
      SELECT
        #{flag},
        'enjoy_vip_price',
        any_value(shop_id),
        any_value(branch_id),
        order_id,
        sum(amount) as amount,
        any_value(created_at),
        any_value(updated_at)
      FROM
        ddt_adjustments
      WHERE
        reason = 'child_enjoy_vip_price'
        group by order_id
    SQL
    flag = "'#{VERSION}_part2_3'"
    puts '*' * 280
    puts "=> #{flag}"
    puts '*' * 280
    execute <<-SQL
      UPDATE ddt_adjustments as a
      INNER JOIN ddt_adjustments as b ON a.order_id = b.order_id
      SET a.parent_id = b.id
      WHERE a.reason = 'child_enjoy_vip_price'
      AND b.reason = 'enjoy_vip_price'
    SQL
    execute "UPDATE ddt_adjustments SET reason = 'enjoy_vip_price' where reason = 'child_enjoy_vip_price'"
  end

  def update_order_adjustment_total
    execute <<-SQL
      UPDATE ddt_orders as orders
      INNER JOIN
      (select
        a.order_id as order_id,
        o.adjustment_total as order_adjustment_total,
        sum(a.amount) as adjustment_total
      from ddt_orders as o
      inner join ddt_adjustments as a on o.id = a.order_id
      where o.deleted_at is null
      and o.pay_item_state = 'paid'
      and a.deleted_at is null
      and a.parent_id is null
      and a.disabled = 0
      group by a.order_id having order_adjustment_total != adjustment_total) as z ON z.order_id = orders.id
      SET orders.adjustment_total = z.adjustment_total;
    SQL
  end



end
