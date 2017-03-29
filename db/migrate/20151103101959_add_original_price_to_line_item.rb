class AddOriginalPriceToLineItem < ActiveRecord::Migration
  def change

    unless column_exists? :ddt_line_items, :original_price
      add_column :ddt_line_items, :original_price, :decimal, precision: 8, scale: 2
    end

    Ddt::LineItem.joins('left join ddt_orders on ddt_line_items.order_id = ddt_orders.id')
                        .where('ddt_line_items.adjustment_total = 0 and ddt_orders.vip_info_id IS NULL')
                        .update_all('original_price = price')
    puts "migrate lintitems that not discount, finish!"


    n = 0
    Ddt::LineItem.where('adjustment_total < 0').find_each do |line_item|
      n += 1
      original_price = line_item.itemable.price rescue line_item.price
      line_item.update_column(:original_price, original_price)
      puts "#{n}th promotion adjustment, finish" if n % 100 == 0
    end

    n = 0
    Ddt::LineItem.joins('left join ddt_orders on ddt_line_items.order_id = ddt_orders.id')
                        .where('ddt_line_items.adjustment_total = 0 and ddt_orders.vip_info_id is not null')
                        .find_each do |line_item|
                          n += 1
                          original_price = line_item.itemable.price rescue line_item.price
                          line_item.update_column(:original_price, original_price)
                          puts "#{n}th migrate lineitems that discount! line_item.id = #{line_item.id}" if n % 100 == 0
                        end

  end
end
