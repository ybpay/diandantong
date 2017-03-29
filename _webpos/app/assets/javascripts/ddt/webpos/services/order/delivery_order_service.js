WebposModules.add_service('delivery_order')
angular.module('webpos.services.delivery_order', []).
  factory('DeliveryOrderService', ['$resource', 'BaseOrderService', function($resource, BaseOrderService){
    var DeliveryOrder = BaseOrderService.get_resource("delivery")
    function create(branch_id, params, success){
      DeliveryOrder.save({branch_id: branch_id}, params, success)
    }

    function assign_delivery_man(branch_id, order_id, delivery_man_id, success){
      DeliveryOrder.assign_delivery_man({ branch_id: branch_id, id: order_id },{ delivery_man_id: delivery_man_id }, success)
    }

    return {
      create: create,
      assign_delivery_man: assign_delivery_man
    }
  }])