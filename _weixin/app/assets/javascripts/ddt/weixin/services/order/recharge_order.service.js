Ddt.factory('RechargeOrderService',
  ['BaseOrderService',
    function (BaseOrderService) {
      var order_type = 'recharge'

      function create(branch_id, order_params, success){
        BaseOrderService.create(order_type, branch_id, order_params, success)
      }

      return {
        create: create
      }
  }]);