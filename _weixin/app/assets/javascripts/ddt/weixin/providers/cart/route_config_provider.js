angular.module('ddt_app.route_config.cart', []).
  provider('RouteConfig', function () {
    this.$get = function(){
        var all_configs = []

        var table_configs = [
          {
            path:        '/branches/:branch_id/tables/:table_id',
            templateUrl: '/cart/tables/show.html',
            controller:  'tableController',
            feature:     'eat_in_hall_on_wechat',
          },
          {
            path:         '/branches/:branch_id/tables/:table_id/merge_order_itemables',
            templateUrl:  '/cart/carts/show.html',
            controller:   'tableCartController',
            feature:      'eat_in_hall_on_wechat',
          },
          {
            path:         '/branches/:branch_id/selecttable',
            templateUrl:  '/cart/tables/selecttable.html',
            controller:   'tableSelectController',
            feature:      'eat_in_hall_on_wechat',
          }
        ]

        var product_configs = [
          {
            path:         '/branches/:branch_id/products/delivery',
            templateUrl:  '/cart/products/delivery.html',
            controller:   'deliveryProductsController',
            feature:      'delivery_on_wechat'
          },
          {
            path:         '/branches/:branch_id/products/eat_in_hall',
            templateUrl:  '/cart/products/eat_in_hall.html',
            controller:   'eatInHallProductsController',
            feature:      'eat_in_hall_on_wechat',
          },
          {
            path:         '/branches/:branch_id/products/reservation',
            templateUrl:  '/cart/products/reservation.html',
            controller:   'reservationProductsController',
            feature:      'reservation_on_wechat'
          },
          {
            path:         '/branches/:branch_id/products/queue_pre_ordering',
            templateUrl:  '/cart/products/queue_pre_ordering.html',
            controller:   'queuePreOrderingProductsController',
            feature:      'reservation_on_wechat'
          },
          {
            path:         '/branches/:branch_id/products/fastfood',
            templateUrl:  '/cart/products/fastfood.html',
            controller:   'fastfoodProductsController',
            feature:      'fastfood_on_wechat'
          },
          {
            path:         '/branches/:branch_id/products/search',
            templateUrl:  '/cart/products/search.html',
            controller:   'searchProductsController',
            feature:      'model_product'
          },
          {
            path:         '/branches/:branch_id/products/:product_id',
            templateUrl:  '/cart/products/show.html',
            controller:   'productController',
            feature:      'model_product'
          }
        ]

        var cart_configs = [
          {
            path:         '/branches/:branch_id/cart/:cart_type',
            templateUrl:  '/cart/carts/show.html',
            controller:   'cartController'
          }
        ]

        var combo_configs = [
          {
            path:         '/branches/:branch_id/combos',
            templateUrl:  '/cart/combos/index.html',
            controller:   'combosController',
            feature:      'model_combo'
          },
          {
            path:         '/branches/:branch_id/orders/:order_id/:order_type/append_combo',
            templateUrl:  '/cart/combos/index.html',
            controller:   'combosController',
            feature:      'model_combo'
          }
        ]

        var reservation_configs = [
          {
            path:         '/branches/:branch_id/reservation_time_points',
            templateUrl:  '/cart/orders/reservation/choose_time_point.html',
            controller:   'reservationTimePointsController',
            feature:      'reservation_on_wechat'
          }
        ]

        var order_configs = [
          {
            path:         '/branches/:branch_id/orders/delivery/new',
            templateUrl:  '/cart/orders/delivery/new.html',
            controller:   'newDeliveryOrderController',
            feature:      'delivery_on_wechat'
          },
          {
            path:         '/branches/:branch_id/orders/eat_in_hall/new',
            templateUrl:  '/cart/orders/eat_in_hall/new.html',
            controller:   'newEatInHallOrderController',
            feature:       'eat_in_hall_on_wechat'
          },
          {
            path:         '/branches/:branch_id/orders/fastfood/new',
            templateUrl:  '/cart/orders/fastfood/new.html',
            controller:   'newFastfoodOrderController',
            feature:      'fastfood_on_wechat'
          },
          {
            path:         '/branches/:branch_id/orders/reservation/new',
            templateUrl:  '/cart/orders/reservation/new.html',
            controller:   'newReservationOrderController',
            feature:      'reservation_on_wechat'
          },
          {
            path:         '/branches/:branch_id/orders/groupon/new',
            templateUrl:  '/cart/orders/groupon/new.html',
            controller:   'newGrouponOrderController',
            feature:      'base_groupon'
          },
          {
            path:         '/branches/:branch_id/orders/recharge/new',
            templateUrl:  '/cart/orders/recharge/new.html',
            controller:   'newRechargeOrderController',
            feature:      'model_recharge_order'
          },
          {
            path:         '/branches/:branch_id/orders/:order_id/:order_type/append_itemable',
            templateUrl:  '/cart/orders/append_itemable.html',
            controller:   'orderAppendItemableController'
          },
          {
            path:         '/branches/:branch_id/orders/:order_id/:order_type/append_itemable_confirm',
            templateUrl:  '/cart/orders/append_itemable_confirm.html',
            controller:   'orderAppendItemableConfirmController'
          },
          {
            path:         '/branches/:branch_id/order_success/:order_id/:order_type',
            templateUrl:  '/success.html',
            controller:   'orderSuccessController'
          },
        ]

        var pay_online_configs = [{
          path:           '/branches/:branch_id/pay_online',
          templateUrl:    '/cart/pay_onlines/new.html',
          controller:     'newPayOnlineController'
        }];

        var address_configs = [
          {
            path:         '/addresses',
            templateUrl:  '/cart/address/addresses.html',
            controller:   'addressesController',
            feature:      'model_address'
          },
          {
            path:         '/addresses/new',
            templateUrl:  '/cart/address/address.html',
            controller:   'newAddressController',
            feature:      'model_address'
          },
          {
            path:         '/addresses/:address_id/edit',
            templateUrl:  '/cart/address/address.html',
            controller:   'editAddressController',
            feature:      'model_address'
          }
        ];

        var tuan_configs = [
          {
            path:         '/tuans',
            templateUrl:  '/cart/tuans/index.html',
            controller:   'tuansController',
            feature:      'base_groupon'
          },
          {
            path:         '/tuans/:tuan_id',
            templateUrl:  '/cart/tuans/show.html',
            controller:   'tuanController',
            feature:      'base_groupon'
          }
        ]


        add_config(table_configs);
        add_config(product_configs);
        add_config(combo_configs);
        add_config(cart_configs);
        add_config(pay_online_configs);
        add_config(address_configs);
        add_config(reservation_configs);
        add_config(order_configs);
        add_config(tuan_configs);

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
