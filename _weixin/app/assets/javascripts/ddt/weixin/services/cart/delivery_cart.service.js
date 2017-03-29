Ddt.factory('DeliveryCartService',
  ['BaseCartService',
    function (BaseCartService) {
      var cart_type = 'delivery'
      function get(branch_id, success){
        BaseCartService.get(cart_type, branch_id, success)
      }

      function add_itemable(branch_id, itemable, success){
        BaseCartService.add_itemable(cart_type, branch_id, itemable, success)
      }

      function remove_itemable(branch_id, itemable, success){
        BaseCartService.remove_itemable(cart_type, branch_id, itemable, success)
      }

      function clear(branch_id, success){
        BaseCartService.clear(cart_type, branch_id, success)
      }

      function update_cart(branch_id, cart_params, success){
        BaseCartService.update_cart(cart_type, branch_id, cart_params, success)
      }

      function update_shipment(branch_id, shipment_params, success){
        var resource = BaseCartService.get_resource(cart_type)
        resource.update_shipment({branch_id: branch_id }, {
          shipment: shipment_params
        }, success)
      }

      return {
        get: get,
        add_itemable: add_itemable,
        remove_itemable: remove_itemable,
        clear: clear,
        update_cart: update_cart,
        update_shipment: update_shipment
      }
  }]);
