module Ddt
  module Backend
		module BusinessStatisticsHelper
			def search_operator_name_by_order order
			  operator_id = order.adjustments.first.operator_id
			  operator_name = Ddt::Account.find_by_id(operator_id).try(:name)
			  operator_name = "系统升级前订单未指定" if operator_name.blank?
			  return operator_name
			end
			  
			def search_authorizer_name_by_order order
			  authorizer_id = order.adjustments.first.authorizer_id
			  authorizer_name = Ddt::Account.find_by_id(authorizer_id).try(:name)
			  authorizer_name = "系统升级前订单未指定" if authorizer_name.blank?
			  return authorizer_name
			end
		end
  end
end