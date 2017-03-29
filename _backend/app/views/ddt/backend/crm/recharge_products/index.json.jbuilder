json.array! @recharge_products do |recharge_product|
  json.(recharge_product, :id, :name, :price, :recharge_amount, :position, :sales_count, :extra_credits, :first_recharge_available_amount,
    :support_all_branch,
    :branch_names, :branch_ids, :branch_ids_string,
    :branch_group_names, :branch_group_ids, :branch_group_ids_string)
end