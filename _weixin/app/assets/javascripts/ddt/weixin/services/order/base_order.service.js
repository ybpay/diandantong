Ddt.factory('BaseOrderService',
  ['$rootScope' , '$resource', 'DdtConst',
    function ( $rootScope, $resource, DdtConst) {
      var common_actions = {
        get_pay_online:      { method: 'get', params: { action: 'get_pay_online'}},
        cancel:              { method: 'post', params: { action: 'cancel'}},
        confirm:             { method: 'post', params: { action: 'confirm'}},
        complete:            { method: 'post', params: { action: 'complete'}},
        append_itemables:    { method: 'post', params: { action: 'append_itemables'}},
        association_domains: { method: 'get', params: { action: 'association_domains'}},
        avariable_coupons:   { method: 'get', params: { action: 'avariable_coupons'}},
        get_permissions:     { method: 'get', params: { action: 'get_permissions'}}
      };
      var DeliveryOrder = $resource(DdtConst.baseUrl + '/branches/:branch_id/delivery_orders/:id/:action',{ format: 'json' },
          angular.extend({
            delivery_zones: {method: 'get', params: {action: 'delivery_zones'}, isArray:true},
            delivery_times: {method: 'get', params: {action: 'delivery_times'}, isArray:true},
            delivery_dates: {method: 'get', params: {action: 'delivery_dates'}, isArray: true},
            hasten: { method: 'post', params: { action: 'hasten'}},
            refresh_location: {method: 'get', params: {action: 'refresh_location'}},
            ship: {method: 'get', params: {action: 'ship'}},
            start_shipment: {method: 'post', params: {action: 'start_shipment'}},
            finish_shipment: {method: 'post', params: {action: 'finish_shipment'}},
            assign_to_self: {method: 'post', params: {action: 'assign_to_self'}},
          }, common_actions));
      var EatInHallOrder = $resource(DdtConst.baseUrl + '/branches/:branch_id/eat_in_hall_orders/:id/:action',{ format: 'json' },
          angular.extend({
            get_order_by_table: { method: 'get', params: { action: 'get_order_by_table' }},
            hasten: { method: 'post', params: { action: 'hasten'}},
            call_waiter: { method: 'post', params: { action: 'call_waiter'}},
            request_pay: { method: 'post', params: { action: 'request_pay'}},
            apply_coupon:      { method: 'post', params: { action: 'apply_coupon'}},
            clear_coupon:      { method: 'post', params: { action: 'clear_coupon'}},
            update: { method: 'post'}
          }, common_actions));
      var FastfoodOrder = $resource(DdtConst.baseUrl + '/branches/:branch_id/fastfood_orders/:id/:action',{ format: 'json' },
          angular.extend({
            hasten: { method: 'post', params: { action: 'hasten'}},
            call_waiter: { method: 'post', params: { action: 'call_waiter'}}
          }, common_actions));
      var ReservationOrder = $resource(DdtConst.baseUrl + '/branches/:branch_id/reservation_orders/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions));
      var GrouponOrder = $resource(DdtConst.baseUrl + '/branches/:branch_id/groupon_orders/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions));
      var RechargeOrder = $resource(DdtConst.baseUrl + '/branches/:branch_id/recharge_orders/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions));
      var PaymentOrder = $resource(DdtConst.baseUrl + '/branches/:branch_id/payment_orders/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions));

      function get_resource(order_type){
        var resource;
        switch(order_type){
          case 'delivery':    ; resource = DeliveryOrder   ; break ;
          case 'eat_in_hall': ; resource = EatInHallOrder  ; break ;
          case 'fastfood':    ; resource = FastfoodOrder   ; break ;
          case 'reservation': ; resource = ReservationOrder; break ;
          case 'groupon':     ; resource = GrouponOrder    ; break ;
          case 'recharge':    ; resource = RechargeOrder    ; break ;
          case 'payment':     ; resource = PaymentOrder    ; break ;
        }
        return resource;
      }

    function create(order_type, branch_id, order_params, success){
      var resource = get_resource(order_type)
      resource.save({ branch_id: branch_id }, {
        order: order_params
      }, function(resp){
        // SnapCartService.destroy(order_type, branch_id)
        // ProductService.expire_cache();
        // UserService.refresh();

        // $rootScope.$broadcast('event:order_created', {
        //     order_type: order_type,
        //     branch_id: branch_id
        //   }
        // )
        if(success){ success(resp) }
      })
    }

    function update(order_type, branch_id, order_id, order_params, success){
      var resource = get_resource(order_type)
      resource.update({branch_id: branch_id, id: order_id}, {
        order: order_params
      }, function(resp){
        if(success){success(resp)}
      })
    }

    function append_itemables(order_type, branch_id, order_id, itemables, success){
      var resource = get_resource(order_type);
      resource.append_itemables({branch_id: branch_id, id: order_id}, {
        itemables: itemables
      }, success);
    }

    function apply_coupon(order_type, branch_id, order_id, coupon_id, success){
      var resource = get_resource(order_type);
      resource.apply_coupon({branch_id: branch_id, id: order_id}, {coupon_id: coupon_id}, success);
    }

    function clear_coupon(order_type, branch_id, order_id, success){
      var resource = get_resource(order_type);
      resource.clear_coupon({branch_id: branch_id, id: order_id}, {}, success);
    }

    var service = {};
    angular.forEach(['get', 'get_pay_online', 'cancel', 'confirm', 'complete', 'get_permissions', 'avariable_coupons'], function(method){
      service[method] = function(order_type, branch_id, order_id, success){
        var resource = get_resource(order_type);
        resource[method]({branch_id: branch_id, id: order_id}, {}, success);
      }
    });

    angular.forEach(['association_domains'], function(method){
      service[method] = function(order_type, branch_id, success){
        var resource = get_resource(order_type);
        resource[method]({branch_id: branch_id}, {}, success);
      }
    });


    return angular.extend(service, {
      create: create,
      update: update,
      append_itemables: append_itemables,
      get_resource: get_resource,
      apply_coupon: apply_coupon,
      clear_coupon: clear_coupon
    });
  }]);
