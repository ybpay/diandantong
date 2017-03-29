WebposModules.add_service('pay_item')
angular.module('webpos.services.pay_item',[]).
  factory('PayItemService',['$resource', '$rootScope', function($resource, $rootScope){
    var PayItem = $resource('/branches/:branch_id/orders/:order_id/pay_items/:id/:action',{},{
      paid: { method: "post", params: {action: "paid"}},
      get_pay_online: { method: 'post', params: {action: 'get_pay_online'}},
      pay_by_seller_scan: { method: 'post', params: {action: 'pay_by_seller_scan'}},
      close: {method: "post", params: {action: 'close'}},
      refund: {method: 'post', params: {action: 'refund'}}
    })

    function paid(branch_id, order_id, pay_item_id, params, success){
      var params = $.extend(params, {is_local_printed: $rootScope.local_printer_configed()})
      PayItem.paid({branch_id: branch_id, order_id: order_id, id: pay_item_id},
        $.extend(params, {
          is_local_printed: $rootScope.local_printer_configed(),
          bill_type: $rootScope.order_bill_type()
        }), success);
    }

    function get(branch_id, order_id, pay_item_id, success){
      PayItem.get({
        branch_id: branch_id,
        order_id: order_id,
        id: pay_item_id,
        is_local_printed: $rootScope.local_printer_configed(),
        bill_type: $rootScope.order_bill_type()
      }, success);
    }

    function get_pay_online(branch_id, order_id, pay_item_id, replace, success){
      PayItem.get_pay_online({branch_id: branch_id, order_id: order_id, id: pay_item_id, replace: replace}, {}, success);
    }

    function pay_by_seller_scan(branch_id, order_id, pay_item_id, dynamic_id, success){
      PayItem.pay_by_seller_scan({branch_id: branch_id, order_id: order_id, id: pay_item_id}, { dynamic_id: dynamic_id }, success);
    }

    function close(branch_id, order_id, pay_item_id, success){
      PayItem.close({branch_id: branch_id, order_id: order_id, id: pay_item_id}, {}, success)
    }

    function refund(branch_id, order_id, pay_item_id, success){
      PayItem.refund({branch_id: branch_id, order_id: order_id, id: pay_item_id}, {}, success)
    }

    return{
      paid: paid,
      get: get,
      get_pay_online: get_pay_online,
      pay_by_seller_scan: pay_by_seller_scan,
      close: close,
      refund: refund
    }
  }])
