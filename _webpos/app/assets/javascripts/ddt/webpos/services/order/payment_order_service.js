WebposModules.add_service('payment_order')
angular.module('webpos.services.payment_order', []).
  factory('PaymentOrderService', ['$resource', 'BaseOrderService', function($resource, BaseOrderService){
    var PaymentOrder = BaseOrderService.get_resource("payment")
    function create(branch_id, params, success){
      PaymentOrder.save({branch_id: branch_id}, params, success)
    }

    return {
      create: create
    }
  }])