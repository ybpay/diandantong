json.extract! @guest_queue, :id, :branch_id, :base_user_id, :queue_setting_id, :guest_no, :guest_num , :workflow_state, :workflow_state_name, :is_notified, :phone, :created_at, :track_from, :track_from_name, :is_binded, :bind_state_label
json.has_pre_order @guest_queue.pre_order_itemables.present?
