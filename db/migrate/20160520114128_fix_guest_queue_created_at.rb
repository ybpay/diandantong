class FixGuestQueueCreatedAt < ActiveRecord::Migration
  def up
    if index_exists? :ddt_guest_queues, :queue_setting_id
      remove_index :ddt_guest_queues, :queue_setting_id
    end
    unless index_exists? :ddt_guest_queues, [:queue_setting_id, :workflow_state, :created_at], :name => "queue_setting_id_union_index"
      add_index :ddt_guest_queues, [:queue_setting_id, :workflow_state,:created_at], :name => "queue_setting_id_union_index"
    end
  end

  def down
    if index_exists? :ddt_guest_queues, [:queue_setting_id, :workflow_state, :created_at], :name => "queue_setting_id_union_index"
      remove_index :ddt_guest_queues, :name => "queue_setting_id_union_index"
    end
    unless index_exists? :ddt_guest_queues, :queue_setting_id
      add_index :ddt_guest_queues, :queue_setting_id
    end
  end
end
