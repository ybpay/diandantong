json.extract! @merchant_apply, :phone, :note
json.state @merchant_apply.workflow_state
json.state_name @merchant_apply.workflow_state_name
