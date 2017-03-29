WebposModules.add_service('table_cart')
angular.module('webpos.services.table_cart', []).
  factory('TableCartService', ['$resource','EatInHallOrderService','BaseSnapCartService',
    function($resource, EatInHallOrderService, BaseSnapCartService){
    var table_id = null
    var carts = {}

    function set_table_id(id){
      table_id = id
    }

    function get(branch_id, success){
      var cart = undefined;
      if(table_id){
        cart = carts[table_id]
      }
      if(cart){
        if(success){ success(cart) }
      }else{
        var cart = BaseSnapCartService.new_cart()
        set_cart(cart)
        if(success){ success(cart)}
      }
    }

    function set_cart(cart){
      if(!cart){
        delete carts[table_id];
      }else{
        carts[table_id] = cart
      }
    }

    function change_note(branch_id, itemable, note, success){
      get(branch_id, function(cart){
        BaseSnapCartService.change_note(cart, itemable, note, success)
      })
    }

    function add_itemable(branch_id, itemable, success){
      do_add_itemable(branch_id, itemable, success)
    }

    function add_itemable_separate(branch_id, itemable, success){
      do_add_itemable(branch_id, itemable, success, {is_separate: true})
    }

    function do_add_itemable(branch_id, itemable, success, options){
      get(branch_id, function(cart){
        BaseSnapCartService.add_itemable(cart, itemable, success, options)
      })
    }

    function remove_itemable(branch_id, itemable, success){
      get(branch_id, function(cart){
        BaseSnapCartService.remove_itemable(cart, itemable, success)
      })
    }

    function update_itemable(branch_id, itemable, success){
      get(branch_id, function(cart){
        BaseSnapCartService.update_itemable(cart, itemable, success)
      });
    }

    function place_cart(branch_id, table_id, params, success){
      get(branch_id, function(cart){
        EatInHallOrderService.create(branch_id, {
          cart: {
            table_id: table_id,
            line_items_attributes: BaseSnapCartService.change_to_line_items_attributes(cart),
          },
          is_local_printed: params.is_local_printed,
          note:             params.note,
          bill_type:        params.bill_type
        }, function(cart){
          success(cart)
          destroy()
        })
      })
    }

    function destroy(){
      set_cart(null)
      table_id = null
    }

    function clear(branch_id, success){
      set_cart(null)
      get(branch_id, success)
    }


    return {
      set_table_id: set_table_id,
      get: get,
      set_cart: set_cart,
      change_note: change_note,
      add_itemable: add_itemable,
      update_itemable: update_itemable,
      add_itemable_separate: add_itemable_separate,
      remove_itemable: remove_itemable,
      clear: clear,
      destroy: destroy,
      place_cart: place_cart
    }
  }])
