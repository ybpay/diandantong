angular.module('ddt_app.route_config.manage', []).
  provider('RouteConfig', function () {
    this.$get = function(){
        var all_configs = []

        var base_configs = [
           {
            path:         '/',
            templateUrl:  '/manage/index.html',
          },
        ]

        var order_configs = [
          {
            path:         '/branches/:branch_id/orders/:order_type/:order_id',
            templateUrl:  '/manage/orders/show.html',
            controller:   'orderController'
          },
          {
            path:         '/delivery_orders',
            templateUrl:  '/manage/orders/delivery_orders.html',
            controller:   'deliveryOrdersController'
          }
        ]

        add_config(base_configs);
        add_config(order_configs);

        function get(){
          return all_configs;
        }

        function add_config(config){
          all_configs = all_configs.concat(config)
        }

        return {
            get: get
        }
    }
  })
