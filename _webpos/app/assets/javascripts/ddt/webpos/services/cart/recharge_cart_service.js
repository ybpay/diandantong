WebposModules.add_service('recharge_cart')
angular.module('webpos.services.recharge_cart', []).
  factory('RechargeCartService', ['$resource','BaseSnapCartService','RechargeOrderService',
    function($resource, BaseSnapCartService, RechargeOrderService){
    var carts = {}

    function get(branch_id, success){
      var cart = carts[branch_id]
      if(cart){
        if(success){ success(cart) }
      }else{
        var cart = BaseSnapCartService.new_cart()
        set_cart(branch_id, cart)
        if(success){ success(cart)}
      }
    }

    function set_cart(branch_id, cart){
      carts[branch_id] = cart
    }

    function change_note(branch_id, itemable, note, success){
      get(branch_id, function(cart){
        BaseSnapCartService.change_note(cart, itemable, note, success)
      })
    }

    function add_itemable_separate(branch_id, itemable, success){
      do_add_itemable(branch_id, itemable, success, {is_separate: true})
    }

    function add_itemable(branch_id, itemable, success){
      do_add_itemable(branch_id, itemable, success)
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

    function place_cart(branch_id, params, success){
      get(branch_id, function(cart){
        RechargeOrderService.create(branch_id, {
          cart: {
            line_items_attributes: BaseSnapCartService.change_to_line_items_attributes(cart),
            note: params.note,
            vip_info_id: params.vip_info_id
          },
        }, function(resp){
          success(resp);
          clear(branch_id, function(){})
        })
      })
    }

    function clear(branch_id, success){
      set_cart(branch_id, BaseSnapCartService.new_cart())
      get(branch_id, success)
    }


    return {
      get: get,
      set_cart: set_cart,
      change_note: change_note,
      add_itemable: add_itemable,
      update_itemable: update_itemable,
      add_itemable_separate: add_itemable_separate,
      remove_itemable: remove_itemable,
      clear: clear,
      place_cart: place_cart
    }
  }])
