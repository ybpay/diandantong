WebposModules.add_service('bill_center')
angular.module('webpos.services.bill_center', []).
  factory('BillCenterService', ['$resource', function($resource){
    var BillCenter = $resource('/branches/:branch_id/bill_center/:action', {},{
        discount_list:        { method: 'get', params: { action: 'discount_list'}},
        gift_item_list:       { method: 'get', params: { action: 'gift_item_list'}},
        subtract_item_list:   { method: 'get', params: { action: 'subtract_item_list'}},
        sale_list:            { method: 'get', params: { action: 'sale_list'}},
        payment_list:         { method: 'get', params: { action: 'payment_list'}},
        shift_list:           { method: 'get', params: { action: 'shift_list'}},
        combo_package_list:   { method: 'get', params: { action: 'combo_package_list'}},
        anti_settlement_list: { method: 'get', params: { action: 'anti_settlement_list'}},
        order_cancel_list:    { method: 'get', params: { action: 'order_cancel_list'}},
        waiter_list:          { method: 'get', params: { action: 'waiter_list'}},
        queue_list:           { method: 'get', params: { action: 'queue_list'}},
        by_weight_product_list: { method: 'get', params: { action: 'by_weight_product_list'}},
      });

    var service = {}
    var lists = ['discount_list','gift_item_list', 'subtract_item_list', 'sale_list', 'payment_list', 'shift_list', 'combo_package_list', 'anti_settlement_list', 'order_cancel_list', 'waiter_list', 'queue_list','by_weight_product_list'];
    angular.forEach(lists, function(list_name){
      service[list_name] = function(branch_id, params, success){
        BillCenter[list_name](angular.extend({branch_id: branch_id}, params), success)
      }
    })

    return service
  }])
