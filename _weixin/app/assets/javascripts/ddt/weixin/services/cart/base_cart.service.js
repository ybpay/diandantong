Ddt.factory('BaseCartService',
  ['$rootScope', '$resource', 'DdtConst',
    function ($rootScope, $resource, DdtConst) {
      var cache_carts = {};
      var common_actions = {
        add_itemable:      { method: 'post', params: { action: 'add_itemable' }},
        remove_itemable:   { method: 'post', params: { action: 'remove_itemable'}},
        clear:             { method: 'post', params: { action: 'clear'}},
        update_cart:       { method: 'post', params: { action: 'update_cart'}},
        add_combo_package: { method: 'post', params: { action: 'add_combo_package'}},
      }
      var DeliveryCart = $resource(DdtConst.baseUrl + '/branches/:branch_id/delivery_cart/:action',{ format: 'json' },
          angular.extend({
            update_shipment: { method: 'post', params: { action: 'update_shipment' }},
            apply_coupon:      { method: 'post', params: { action: 'apply_coupon'}},
            clear_coupon:      { method: 'post', params: { action: 'clear_coupon'}},
          }, common_actions))
      var EatInHallCart = $resource(DdtConst.baseUrl + '/branches/:branch_id/eat_in_hall_cart/:action',{ format: 'json' },
        angular.extend({
            update_table_info: { method: 'post', params: { action : 'update_table_info'}},
            apply_coupon:      { method: 'post', params: { action: 'apply_coupon'}},
            clear_coupon:      { method: 'post', params: { action: 'clear_coupon'}},
            set_order_itemables_from_table:{ method: 'post', params: { action: 'set_order_itemables_from_table'}},
          }, common_actions))
      var FastfoodCart = $resource(DdtConst.baseUrl + '/branches/:branch_id/fastfood_cart/:action',{ format: 'json' },
          angular.extend({
            apply_coupon:      { method: 'post', params: { action: 'apply_coupon'}},
            clear_coupon:      { method: 'post', params: { action: 'clear_coupon'}},
          }, common_actions))
      var ReservationCart = $resource(DdtConst.baseUrl + '/branches/:branch_id/reservation_cart/:action',{ format: 'json' },
          angular.extend({
            update_reservation_info: { method: 'post', params: { action : 'update_reservation_info'}},
          }, common_actions))
      var GrouponCart = $resource(DdtConst.baseUrl + '/branches/:branch_id/groupon_cart/:action',{ format: 'json' },
          angular.extend({
            add_tuan: { method: 'post', params: { action: 'add_tuan'}}
          }, common_actions))
      var RechargeCart = $resource(DdtConst.baseUrl + '/branches/:branch_id/recharge_cart/:action',{ format: 'json' },
          angular.extend({
            add_recharge_product: { method: 'post', params: { action: 'add_recharge_product'}}
          }, common_actions))
      var PaymentCart = $resource(DdtConst.baseUrl + '/branches/:branch_id/payment_cart/:action',{ format: 'json' },
          angular.extend({}, common_actions))

      function get_resource(cart_type){
        var resource;
        switch(cart_type){
          case 'delivery':     resource = DeliveryCart   ; break ;
          case 'eat_in_hall':  resource = EatInHallCart  ; break ;
          case 'fastfood':     resource = FastfoodCart   ; break ;
          case 'reservation':  resource = ReservationCart ; break ;
          case 'groupon':      resource = GrouponCart ; break ;
          case 'recharge':     resource = RechargeCart ; break ;
          case 'payment':      resource = PaymentCart ; break ;
        }
        return resource
      }

      function get(cart_type, branch_id, success){
        var resource = get_resource(cart_type)
        resource.get({ branch_id: branch_id }, success)
      }

      function add_itemable(cart_type, branch_id, itemable, success){
        var resource = get_resource(cart_type)
        if(!$rootScope.is_submiting){
          $rootScope.is_submiting = true;
          resource.add_itemable({branch_id: branch_id}, {
            itemable_type: itemable.itemable_type,
            itemable_id: itemable.itemable_id,
            note: itemable.note || '',
          }, function(cart){
            success(cart)
            $rootScope.is_submiting = false;
          })
        }

      }

      function remove_itemable(cart_type, branch_id, itemable, success){
        var resource = get_resource(cart_type)
        if(!$rootScope.is_submiting){
          $rootScope.is_submiting = true;
          resource.remove_itemable({branch_id: branch_id}, {
            itemable_type: itemable.itemable_type,
            itemable_id: itemable.itemable_id,
            note: itemable.note || ''
          }, function(cart){
            success(cart)
            $rootScope.is_submiting = false;
          })
        }
      }

      function clear(cart_type, branch_id, success){
        var resource = get_resource(cart_type)
        resource.clear({ branch_id: branch_id }, success)
      }

      function update_cart(cart_type, branch_id, cart_params, success){
        var resource = get_resource(cart_type)
        resource.update_cart({ branch_id: branch_id },{
          cart: cart_params
        }, function(cart){
          cache_carts[cart_type] = cart;
          success(cart);
        })
      }

      function apply_coupon(cart_type, branch_id, coupon_id, success){
        var resource = get_resource(cart_type);
        resource.apply_coupon({branch_id: branch_id}, {coupon_id: coupon_id}, success);
      }

      function clear_coupon(cart_type, branch_id, success){
        var resource = get_resource(cart_type);
        resource.clear_coupon({branch_id: branch_id}, {}, success);
      }

      function add_combo_package(cart_type, branch_id, params, success){
        var resource = get_resource(cart_type);
        resource.add_combo_package({branch_id: branch_id}, { combo_package: params }, success);
      }

      function set_cache_cart(cart_type, branch_id, cart){
        cache_carts[cart_type] = cart
      }

      function get_cache_cart(cart_type, branch_id, success){
        if(cache_carts[cart_type]){
          success(cache_carts[cart_type])
        }else{
          get(cart_type, branch_id, success)
        }
      }

      return {
        get_resource: get_resource,
        get: get,
        set_cache_cart: set_cache_cart,
        get_cache_cart: get_cache_cart,
        add_itemable: add_itemable,
        remove_itemable: remove_itemable,
        clear: clear,
        update_cart: update_cart,
        apply_coupon: apply_coupon,
        clear_coupon: clear_coupon,
        add_combo_package: add_combo_package
      }
  }]);
