Ddt.factory('DeliveryOrderService',
  ['BaseOrderService',
    function (BaseOrderService) {
      var order_type = 'delivery'

      var delegate = {};
      delegate.create = function(branch_id, order_params, success){
        BaseOrderService.create(order_type, branch_id, order_params, success);
      };

      function delivery_zones(branch_id, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.delivery_zones({ branch_id: branch_id }, success)
      }

      function delivery_times(branch_id, delivery_date, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.delivery_times({ branch_id: branch_id, delivery_date: delivery_date}, success)
      }

      function delivery_dates(branch_id, success) {
        var resource = BaseOrderService.get_resource(order_type);
        resource.delivery_dates({branch_id: branch_id}, success);
      }

      function hasten(branch_id, order_id, line_item_id, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.hasten({ branch_id: branch_id, id: order_id }, {line_item_id: line_item_id}, success)
      }

      function refresh_location(branch_id, order_id, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.refresh_location({ branch_id: branch_id, id: order_id}, success);
      }

      function ship(branch_id, order_id, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.ship({ branch_id: branch_id, id: order_id}, success);
      }

      function start_shipment(branch_id, order_id, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.start_shipment({branch_id: branch_id, id: order_id}, {}, success)
      }

      function finish_shipment(branch_id, order_id, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.finish_shipment({branch_id: branch_id, id: order_id}, {}, success)
      }

      function assign_to_self(branch_id, order_id, success){
        var resource = BaseOrderService.get_resource(order_type)
        resource.assign_to_self({branch_id: branch_id, id: order_id}, {}, success)
      }

      return angular.extend(delegate, {
        delivery_zones: delivery_zones,
        delivery_times: delivery_times,
        delivery_dates: delivery_dates,
        refresh_location: refresh_location,
        ship: ship,
        hasten: hasten,
        start_shipment: start_shipment,
        finish_shipment: finish_shipment,
        assign_to_self: assign_to_self
      });
    }]);
