Ddt.factory('FastfoodOrderService',
  ['BaseOrderService',
    function (BaseOrderService) {
      var order_type = 'fastfood'

      function create(branch_id, order_params, success){
        BaseOrderService.create(order_type, branch_id, order_params, success)
      }

      function hasten(branch_id, order_id, line_item_id, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.hasten({ branch_id: branch_id, id: order_id }, {line_item_id: line_item_id}, success)
      }

      function call_waiter(branch_id, order_id, service_name, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.call_waiter({ branch_id: branch_id, id: order_id, service_name: service_name }, {}, success)
      }

      return {
        create: create,
        hasten: hasten,
        call_waiter: call_waiter
      }
  }]);
