WebposModules.add_service('recharge_order')
angular.module('webpos.services.recharge_order', []).
  factory('RechargeOrderService', ['$resource', 'BaseOrderService', function($resource, BaseOrderService){
    var RechargeOrder = BaseOrderService.get_resource("recharge")
    function create(branch_id, params, success){
      RechargeOrder.save({branch_id: branch_id}, params, success)
    }

    return {
      create: create
    }
  }])