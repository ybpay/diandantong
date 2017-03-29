WebposModules.add_service('delivery_cart')
angular.module('webpos.services.delivery_cart', []).
  factory('DeliveryCartService', ['$resource','BaseSnapCartService','DeliveryOrderService',
    function($resource, BaseSnapCartService, DeliveryOrderService){
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
      do_add_itemable(branch_id, itemable, success, {is_separate: true});
    }

    function add_itemable(branch_id, itemable, success){
      do_add_itemable(branch_id, itemable, success);
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
      })
    }


    function place_cart(branch_id, params, success){
      get(branch_id, function(cart){
        DeliveryOrderService.create(branch_id, {
          cart: { line_items_attributes: BaseSnapCartService.change_to_line_items_attributes(cart) },
          user: {
            phone:            params.phone,
            name:             params.name,
            building:         params.building,
            latitude:         params.latitude,
            longitude:        params.longitude,
            room_no:          params.room_no,
            delivery_zone_id: (params.delivery_zone ? params.delivery_zone.id : null),
            delivery_man_id:  (params.delivery_man ? params.delivery_man.id : null),
            delivery_date:    (params.delivery_date ? params.delivery_date.date : null),
            delivery_time_id: (params.delivery_time ? params.delivery_time.id : null),
            note:             params.note
          },
          order: {
            form_contents: params.form_contents
          },
          bill_type: params.bill_type,
          is_local_printed: params.is_local_printed
        }, function(cart){
          success(cart);
          clear(branch_id, function(new_cart){})
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
