WebposModules.add_service('fastfood_order')
angular.module('webpos.services.fastfood_order', []).
  factory('FastfoodOrderService', ['$resource', 'BaseOrderService', function($resource, BaseOrderService){
    var order_type = 'fastfood'
    var FastfoodOrder = $resource("/branches/:branch_id/fastfood_orders/:id/:action",{},{
      create: { method: 'post', params: {}},
      call_customer: { method: 'get', params: {action: 'call_customer'}},
      anti_settlement: { method: 'post', params: { action: 'anti_settlement'}}
    })


    function create(branch_id, params, success){
      FastfoodOrder.create({ branch_id: branch_id }, params, success)
    }

    function call_customer(branch_id, order_id, success){
      FastfoodOrder.call_customer({branch_id: branch_id, id: order_id}, success)
    }

    function anti_settlement(branch_id, order_id, success){
      FastfoodOrder.anti_settlement({ branch_id: branch_id, id: order_id }, { }, success)
    }

    function hasten(branch_id, order_id, params, success){
      BaseOrderService.hasten(order_type, branch_id, order_id, params, success)
    }

    return {
      create: create,
      call_customer: call_customer,
      hasten: hasten,
      anti_settlement: anti_settlement
    }
  }])
