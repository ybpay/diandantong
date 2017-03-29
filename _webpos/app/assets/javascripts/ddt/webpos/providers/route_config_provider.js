angular.module('webpos.route_config',[]).
  provider('RouteConfig',function(){
    this.$get = function(){
      var all_configs = [];

      var base_config = [
        {
          path:         '/',
          templateUrl:  '/webpos/partials/shops/show.html',
          controller:   'shopController',
          feature:      'model_shop',
        },
        {
          path:         '/accounts/sign_in',
          templateUrl:  '/webpos/partials/accounts/sign_in.html',
          controller:   'accountController',
          feature:      'model_account',
        },
        {
          path:         '/test',
          templateUrl:  '/webpos/partials/tests/test.html',
          controller:   'testController',
          feature:      'model_shop',
        },
        {
          path:         '/settings',
          templateUrl:  '/webpos/partials/settings/index.html',
          controller:   'settingsController',
          feature:      'model_shop',
        }
      ];

      var branch_config = [
        {
          path:         '/branches/:branch_id/eat_in_hall',
          templateUrl:  '/webpos/partials/branches/eat_in_hall.html',
          controller:   'branchEatInHallController',
          feature:      'model_eat_in_hall',
        },
        {
          path:         '/branches/:branch_id/delivery',
          templateUrl:  '/webpos/partials/branches/delivery.html',
          controller:   'branchDeliveryController',
          feature:      'model_delivery',
        },
        {
          path:         '/branches/:branch_id/reservation',
          templateUrl:  '/webpos/partials/branches/reservation.html',
          controller:   'branchReservationController',
          feature:      'model_reservation',
        },
        {
          path:         '/branches/:branch_id/fast_food',
          templateUrl:  '/webpos/partials/branches/fast_food.html',
          controller:   'branchFastFoodController',
          feature:      'model_fastfood',
        },
        {
          path:         '/branches/:branch_id/payment',
          templateUrl:  '/webpos/partials/branches/payment.html',
          controller:   'branchPaymentController',
          feature:      'model_payment',
        },
        {
          path:         '/branches/:branch_id/notification',
          templateUrl:  '/webpos/partials/branches/notification.html',
          controller:   'branchNotificationController',
          feature:      'model_notification',
        },
        {
          path:         '/branches/:branch_id/bill_center',
          templateUrl:  '/webpos/partials/bills/bill_center.html',
          controller:   'billCenterController',
          feature:      'model_bill_center',
        },
        {
          path:         '/branches/:branch_id/printers',
          templateUrl:  '/webpos/partials/printers/index.html',
          controller:   'PrintersController',
          feature:      'model_printer'
        }
      ]

      var tables_config = [
        {
          path:         '/branches/:branch_id/tables/:table_id/cart',
          templateUrl:  '/webpos/partials/tables/cart.html',
          controller:   'tableCartController',
          feature:      'model_eat_in_hall',
        },
        {
          path:         '/branches/:branch_id/tables/:table_id/order',
          templateUrl:  '/webpos/partials/tables/order.html',
          controller:   'tableOrderController',
          feature:      'model_eat_in_hall',
        }
      ]

      var orders_config = [
        {
          path:         '/branches/:branch_id/orders',
          templateUrl:  '/webpos/partials/orders/index.html',
          controller:   'ordersController',
          feature:      'model_order',
        },
        {
          path:         '/branches/:branch_id/orders/:order_id/settle/:order_type',
          templateUrl:  '/webpos/partials/orders/settle.html',
          controller:   'orderSettleController',
          feature:      'model_order',
        },
        {
          path:         '/branches/:branch_id/vip_infos/:vip_info_id/:base_user_id/orders',
          templateUrl:  '/webpos/partials/orders/index.html',
          controller:   'ordersController',
          feature:      'model_vip_info',
        }
      ];

      var vip_infos_config = [
        {
          path:         '/vip_infos',
          templateUrl:  '/webpos/partials/vip_infos/index.html',
          controller:   'VipInfosController',
          feature:      'model_vip_info',
        },
        {
          path:         '/branches/:branch_id/vip_infos',
          templateUrl:  '/webpos/partials/vip_infos/index.html',
          controller:   'VipInfosController',
          feature:      'model_vip_info',
        }
      ];

      var statistics_config = [
        {
          path:         '/statistics',
          templateUrl:  '/webpos/partials/statistics/index.html',
          controller:   'statisticController',
          feature:      'model_statistic',
        }
      ];

      var guest_queues_config = [
        {
          path:         '/branches/:branch_id/guest_queues',
          templateUrl:  '/webpos/partials/guest_queues/index.html',
          controller:   'guestQueuesController',
          feature:      'model_guest_queue',
        }
      ]

      var promotions_config = [
        {
          path:         '/branches/:branch_id/promotions',
          templateUrl:  '/webpos/partials/promotions/index.html',
          controller:   'promotionController',
          feature:      'model_coupon_exchange',
        }
      ];

      var estimate_clear_config = [
        {
          path:         '/branches/:branch_id/estimate_clear',
          templateUrl:  '/webpos/partials/estimate_clear/index.html',
          controller:   'estimateClearController',
          feature:      'model_estimate_clear',
        }
      ];

      add_config(base_config);
      add_config(branch_config);
      add_config(tables_config);
      add_config(orders_config);
      add_config(vip_infos_config);
      add_config(statistics_config);
      add_config(guest_queues_config);
      add_config(promotions_config);
      add_config(estimate_clear_config);

      function get(){
        return all_configs;
      }
      function add_config(config){
        all_configs = all_configs.concat(config);
      }
      return {
        get: get
      }
    }
  });
