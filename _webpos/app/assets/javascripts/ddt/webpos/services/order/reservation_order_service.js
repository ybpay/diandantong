WebposModules.add_service('reservation_order')
angular.module('webpos.services.reservation_order', []).
  factory('ReservationOrderService', ['$resource', 'BaseOrderService', function($resource, BaseOrderService){
    var ReservationOrder = BaseOrderService.get_resource("reservation")
    function create(branch_id, params, success){
      ReservationOrder.save({branch_id: branch_id}, params, success)
    }

    function change_to_eat_in_hall(branch_id, order_id, params, success){
      ReservationOrder.change_to_eat_in_hall({branch_id: branch_id, id: order_id}, params, success)
    }

    function bind_table(branch_id, order_id, table_id, success){
      ReservationOrder.bind_table({branch_id: branch_id, id: order_id}, { table_id: table_id }, success)
    }

    function edit_reservation_info(branch_id, order_id, params, success){
      ReservationOrder.edit_reservation_info({branch_id: branch_id, id: order_id }, params, success);
    }

    return {
      create: create,
      change_to_eat_in_hall: change_to_eat_in_hall,
      bind_table: bind_table,
      edit_reservation_info: edit_reservation_info,
    }
  }])