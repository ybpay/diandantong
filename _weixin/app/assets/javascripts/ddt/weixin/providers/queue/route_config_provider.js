angular.module('ddt_app.route_config.queue', []).
  provider('RouteConfig', function () {
    this.$get = function(){
        var all_configs = []

        var queue_configs = [{
          path:           '/branches/:branch_id/guest_queue',
          templateUrl:    '/queue/guest_queues/show.html',
          controller:     'guestQueueController',
          feature:        'queue_on_wechat'
        },
        {
          path:           '/branches/:branch_id/guest_queues/new_guest',
          templateUrl:    '/queue/guest_queues/show.html',
          controller:     'guestQueueController',
          feature:        'queue_on_wechat'
        },
        {
          path:           '/branches/:branch_id/guest_queue_qr_code/:qr_code_id',
          templateUrl:    '/queue/guest_queues/bind_user.html',
          controller:     'bindUserGuestQueueController',
          feature:        'queue_on_wechat'
        }];

        add_config(queue_configs);

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
