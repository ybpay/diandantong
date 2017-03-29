class AddLockInfoTable < ActiveRecord::Migration
  def change
    create_table :ddt_competition_resources do |t|
      t.string :owner_type
      t.integer :owner_id
      t.string :name
      t.string :value
      t.timestamps
    end

    add_index :ddt_competition_resources, [:owner_type, :owner_id], name: :index_compeition_resource_on_owner

    index = 0
    Ddt::Shop.all.find_each do |shop|
      Ddt::ShopInitializer.new(shop).create_competition_resource!
      last_order = shop.orders.placed.where("placed_at > ? AND placed_at < ?", Time.now.beginning_of_day, Time.now.end_of_day).order(placed_at: :desc).first
      shop.competition_resources.where(name: :order_number).first.update(value: last_order.number) if last_order.present?
      index += 1
      puts "shop index: #{index}" if index % 100 == 0
    end

    index = 0
    Ddt::QueueSetting.all.find_each do |queue_setting|
      queue_setting.send(:create_competition_resource)
      last_guest_queue = queue_setting.guest_queues.with_queueing_state.where("created_at > ? AND created_at < ?", Time.now.beginning_of_day, Time.now.end_of_day).order(id: :desc).first
      queue_setting.competition_resources.where(name: :guest_queue_guest_no).first.update(value: last_guest_queue.guest_no) if last_guest_queue.present?
      index += 1
      puts "queue_setting index: #{index}" if index % 100 == 0
    end

  end
end
