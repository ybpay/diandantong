angular.module('ddt_app.route_config.order', []).
  provider('RouteConfig', function () {
    this.$get = function(){
        var all_configs = []

        var order_configs = [
          {
            path:          '/',
            templateUrl:   '/order/orders/nav.html',
            controller:    'orderNavController'
          },
          {
            path:          '/orders/nav',
            templateUrl:   '/order/orders/nav.html',
            controller:    'orderNavController'
          },
          {
            path:         '/orders/delivery',
            templateUrl:  '/order/orders/index.html',
            controller:   'deliveryOrdersController',
            feature:      'model_delivery_order'
          },
          {
            path:         '/orders/reservation',
            templateUrl:  '/order/orders/index.html',
            controller:   'reservationOrdersController',
            feature:      'model_reservation_order'
          },
          {
            path:         '/orders/eat_in_hall',
            templateUrl:  '/order/orders/index.html',
            controller:   'eatInHallOrdersController',
            feature:      'model_eat_in_hall_order'
          },
          {
            path:         '/orders/fastfood',
            templateUrl:  '/order/orders/index.html',
            controller:   'fastfoodOrdersController',
            feature:      'model_fastfood_order'
          },
          {
            path:         '/orders/groupon',
            templateUrl:  '/order/orders/index.html',
            controller:   'grouponOrdersController',
            feature:      'base_groupon'
          },
          {
            path:         '/orders/recharge',
            templateUrl:  '/order/orders/index.html',
            controller:   'rechargeOrdersController',
            feature:      'model_vip_info'
          },
          {
            path:         '/orders/payment',
            templateUrl:  '/order/orders/index.html',
            controller:   'paymentOrdersController',
            feature:      'model_payment_order'
          },
          {
            path:         '/branches/:branch_id/orders/delivery/:order_id',
            templateUrl:  '/order/orders/delivery/show.html',
            controller:   'deliveryOrderController',
            feature:      'model_delivery_order'
          },
          {
            path:         '/branches/:branch_id/orders/reservation/:order_id',
            templateUrl:  '/order/orders/reservation/show.html',
            controller:   'reservationOrderController',
            feature:      'model_reservation_order'
          },
          {
            path:         '/branches/:branch_id/orders/eat_in_hall/:order_id',
            templateUrl:  '/order/orders/eat_in_hall/show.html',
            controller:   'eatInHallOrderController',
            feature:      'model_eat_in_hall_order'
          },
          {
            path:         '/branches/:branch_id/orders/fastfood/:order_id',
            templateUrl:  '/order/orders/fastfood/show.html',
            controller:   'fastfoodOrderController',
            feature:      'model_fastfood_order'
          },
          {
            path:         '/branches/:branch_id/orders/groupon/:order_id',
            templateUrl:  '/order/orders/groupon/show.html',
            controller:   'grouponOrderController',
            feature:      'base_groupon'
          },
          {
            path:         '/branches/:branch_id/orders/recharge/:order_id',
            templateUrl:  '/order/orders/recharge/show.html',
            controller:   'rechargeOrderController',
            feature:      'model_vip_info'
          },
          {
            path:         '/branches/:branch_id/orders/payment/:order_id',
            templateUrl:  '/order/orders/payment/show.html',
            controller:   'paymentOrderController',
            feature:      'model_payment_order'
          },
          {
            path:         '/branches/:branch_id/orders/:order_type/:order_id/pay',
            templateUrl:  '/order/orders/pay.html',
            controller:   'payOrderController'
          },
          {
            path:         '/branches/:branch_id/orders/:order_type/:order_id/pay_online',
            templateUrl:  '/order/orders/payment/pay_online.html',
            controller:   'payOnlineController'
          },
          {
            path:         '/branches/:branch_id/orders/:order_type/:order_id/invoice',
            templateUrl:  '/orders/invoice/new.html',
            controller:   'invoiceController'
          },
          {
            path:         '/branches/:branch_id/orders/invitation/:order_id',
            templateUrl:  '/orders/invitation/show.html',
            controller:   'invitationOrderController',
            feature:      'model_invitation_order'
          },
          {
            path:         '/branches/:branch_id/pay_success/:order_type/:order_id',
            templateUrl:  '/success.html',
            controller:   'paySuccessController'
          }
        ]

        var order_comment_configs = [
          {
            path:         '/branches/:branch_id/orders/:order_id/comment/new',
            templateUrl:  '/order/orders/comment/new.html',
            controller:   'newOrderCommentController',
            feature:      'model_order_comment'
          }
        ];


        add_config(order_configs);
        add_config(order_comment_configs);

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
