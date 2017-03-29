Ddt.factory('BaseUserOrderService', [
    '$rootScope' , '$resource', 'DdtConst',
    function ( $rootScope, $resource, DdtConst) {
      var common_actions = {
      }
      var DeliveryOrder = $resource(DdtConst.baseUrl + '/delivery_orders/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions))
      var EatInHallOrder = $resource(DdtConst.baseUrl + '/eat_in_hall_orders/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions))
      var FastfoodOrder = $resource(DdtConst.baseUrl + '/fastfood_orders/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions))
      var ReservationOrder = $resource(DdtConst.baseUrl + '/reservation_orders/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions))
      var GrouponOrder = $resource(DdtConst.baseUrl + '/groupon_orders/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions))
      var RechargeOrder = $resource(DdtConst.baseUrl + '/recharge_orders/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions))
      var PaymentOrder = $resource(DdtConst.baseUrl + '/payment_orders/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions))

      function get_resource(order_type){
        var resource;
        switch(order_type){
          case 'delivery':     ; resource = DeliveryOrder   ; break ;
          case 'eat_in_hall':  ; resource = EatInHallOrder  ; break ;
          case 'fastfood':     ; resource = FastfoodOrder   ; break ;
          case 'reservation':  ; resource = ReservationOrder ; break ;
          case 'groupon':      ; resource = GrouponOrder ; break ;
          case 'recharge':     ; resource = RechargeOrder ; break ;
          case 'payment':      ; resource = PaymentOrder ; break ;
        }
        return resource
      }

    function query(order_type, params, success){
      var resource = get_resource(order_type)
      resource.query(params, success)
    }

    return {
      query: query
    }
  }]);
