Ddt.factory('EatInHallOrderService',
  ['BaseOrderService',
    function (BaseOrderService) {
      var order_type = 'eat_in_hall'

      function create(branch_id, order_params, success){
        BaseOrderService.create(order_type, branch_id, order_params, success)
      }

      function update(branch_id, order_id, order_params, success){
        BaseOrderService.update(order_type, branch_id, order_id, order_params, success)
      }

      function get_order_by_table(branch_id, table_id, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.get_order_by_table({ branch_id: branch_id, table_id: table_id }, success)
      }

      function hasten(branch_id, order_id, line_item_id, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.hasten({ branch_id: branch_id, id: order_id }, {line_item_id: line_item_id}, success)
      }

      function call_waiter(branch_id, order_id, service_name, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.call_waiter({ branch_id: branch_id, id: order_id, service_name: service_name }, {}, success)
      }

      function request_pay(branch_id, order_id, pay_method_name, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.request_pay({ branch_id: branch_id, id: order_id}, {pay_method_name: pay_method_name}, success)
      }

      return {
        create: create,
        update: update,
        get_order_by_table: get_order_by_table,
        hasten: hasten,
        call_waiter: call_waiter,
        request_pay: request_pay
      }
  }]);
