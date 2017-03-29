class CreateTableColors < ActiveRecord::Migration
  def change
    unless ActiveRecord::Migration.table_exists? :ddt_table_colors
      create_table :ddt_table_colors do |t|
        t.string :idle_color, default: '#b3b4b6'
        t.string :opened_color, default: '#fa7072'
        t.string :ordered_color, default: '#71d1fd'
        t.string :check_outing_color, default: '#4c5d65'
        t.string :paid_color, default: '#7dd400'
        t.string :active_color, default: '#f34b3f'
        t.references :shop, index: true
        t.timestamps
      end
    end
    index = 0
    Ddt::Shop.find_each do |shop|
      index += 1
      if index % 100 == 0
        puts "start to migrate the #{index}th shop of id #{shop.id}"
      end
      shop.create_table_color!
    end
  end
end
