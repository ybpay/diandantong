WebposModules.add_service('order')
angular.module('webpos.services.order', []).
  factory('OrderService', ['$resource', function($resource){
    var Order = $resource("/branches/:branch_id/orders/:id/:action",{},{
      batch_change_state: { method: 'post', params: {action: 'batch_change_state'}},
      pending_counts: { method: 'get', params: {action: 'pending_counts'}}
    })

    function query(params, success){
      Order.query(params, success)
    }

    function get(branch_id, order_id, success){
      Order.get({branch_id: branch_id, id: order_id}, success)
    }

    function batch_change_state(branch_id, order_ids, new_state, success){
      var params = {}
      params["order"] = {
        "order_ids" : order_ids
      },
      params["state"] = new_state
      Order.batch_change_state({branch_id: branch_id},params, success)
    }

    function pending_counts(branch_id, success){
      Order.pending_counts({branch_id: branch_id}, success)
    }

    return {
      query: query,
      get: get,
      batch_change_state: batch_change_state,
      pending_counts: pending_counts
    }
  }])