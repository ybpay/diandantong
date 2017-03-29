Ddt.factory('EatInHallCartService',
  ['BaseCartService',
    function (BaseCartService) {
      var cart_type = 'eat_in_hall'
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

      function update_table_info(branch_id, cart_params, success){
        resource = BaseCartService.get_resource(cart_type)
        resource.update_table_info({branch_id: branch_id}, {cart: cart_params}, success)
      }

      function update_cart(branch_id, cart_params, success){
        BaseCartService.update_cart(cart_type, branch_id, cart_params, success)
      }

      function set_order_itemables_from_table(branch_id, table_id, success){
        resource = BaseCartService.get_resource(cart_type)
        resource.set_order_itemables_from_table({ branch_id: branch_id }, {table_id: table_id}, success)
      }

      return {
        get: get,
        add_itemable: add_itemable,
        remove_itemable: remove_itemable,
        clear: clear,
        update_cart: update_cart,
        update_table_info: update_table_info,
        set_order_itemables_from_table: set_order_itemables_from_table
      }
  }]);
