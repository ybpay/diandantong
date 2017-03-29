json.extract! order, :id, :number, :branch_id, :total, :placed_at, :state, :pay_item_state, :shipment_state, :state_name, :pay_method_name, :is_commented, :item_count, :updated_at
json.branch_name order.branch.try(:name)
json.branch_address order.branch.try(:address)
