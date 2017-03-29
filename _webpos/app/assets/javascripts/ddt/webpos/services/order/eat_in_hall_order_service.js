WebposModules.add_service('eat_in_hall_order')
angular.module('webpos.services.eat_in_hall_order', []).
  factory('EatInHallOrderService', ['$rootScope', '$resource', 'BaseOrderService', function($rootScope, $resource, BaseOrderService){

    var EatInHallOrder = BaseOrderService.get_resource("eat_in_hall")

    function create(branch_id, params, success){
      EatInHallOrder.save({branch_id: branch_id}, params, success)
    }

    function change_table(branch_id, order_id, table_id, success){
      EatInHallOrder.change_table({ branch_id: branch_id, id: order_id }, {
        table_id: table_id
      }, success)
    }

    function merge_table(branch_id, order_id, table_id, success){
      EatInHallOrder.merge_table({ branch_id: branch_id, id: order_id }, {
        table_id: table_id
      }, success)
    }

    function move_itemable(branch_id, order_id, moveables, table_id, success){
      EatInHallOrder.move_itemable({ branch_id: branch_id, id: order_id}, {
        moveables: moveables,
        table_id: table_id
      }, success)
    }

    function append(branch_id, order_id, itemables, success){
      EatInHallOrder.append({ branch_id: branch_id, id: order_id}, {
        itemables: itemables
      }, success)
    }

    function active_line_items(branch_id, order_id, success) {
      EatInHallOrder.active_line_items({branch_id: branch_id, id: order_id}, success);
    }

    function subtract(branch_id, order_id, subtractables, success) {
      EatInHallOrder.subtract({branch_id: branch_id, id: order_id}, {
        subtractables: subtractables
      }, success);
    }

    function credits_deduction(branch_id, order_id, credits, success){
      EatInHallOrder.credits_deduction(branch_id, order_id, credits, success)
    }

    function card_deduction(branch_id, order_id, amount, success){
      EatInHallOrder.card_deduction(branch_id, order_id, amount, success)
    }

    function change_vip_info(branch_id, order_id, vip_info_id, success){
      EatInHallOrder.change_vip_info(branch_id, order_id, vip_info_id, success)
    }

    function hasten(branch_id, order_id, params, success){
      EatInHallOrder.hasten({ branch_id: branch_id, id: order_id }, params, success)
    }

    function bind_reservation_order(branch_id, order_id, reservation_order_id, success){
      EatInHallOrder.bind_reservation_order({ branch_id: branch_id, id: order_id }, { reservation_order_id: reservation_order_id }, success)
    }

    function anti_settlement(branch_id, order_id, success){
      EatInHallOrder.anti_settlement({ branch_id: branch_id, id: order_id }, { }, success)
    }

    function trace_waiter(branch_id, order_id, waiter_id, success){
      EatInHallOrder.trace_waiter({branch_id: branch_id, id: order_id},{ waiter_id: waiter_id },success)
    }

    function allow_selfpay(branch_id, order_id, success){
      EatInHallOrder.allow_selfpay({branch_id: branch_id, id: order_id}, {}, success)
    }

    function update_guest_num(branch_id, order_id, guest_num, success){
      EatInHallOrder.update_guest_num({ branch_id: branch_id, id: order_id }, { guest_num: guest_num}, success)
    }

    function change_weight(branch_id, order_id, params, success){
      EatInHallOrder.change_weight({branch_id: branch_id, id: order_id}, params, success)
    }

    return {
      create: create,
      hasten: hasten,
      change_table: change_table,
      merge_table: merge_table,
      move_itemable: move_itemable,
      append: append,
      active_line_items: active_line_items,
      subtract: subtract,
      change_vip_info: change_vip_info,
      credits_deduction: credits_deduction,
      card_deduction: card_deduction,
      bind_reservation_order: bind_reservation_order,
      anti_settlement: anti_settlement,
      trace_waiter: trace_waiter,
      allow_selfpay: allow_selfpay,
      update_guest_num: update_guest_num,
      change_weight: change_weight
    }
  }])
