Ddt.controller('deliveryOrdersController', [
    '$rootScope', '$scope', 'BaseOrdersController',
      function($rootScope, $scope, BaseOrdersController){
      $rootScope.title = '外卖订单';
      $scope.order_type = 'delivery'
      BaseOrdersController.action($scope, function(){})

}]).controller('reservationOrdersController', ['$rootScope', '$scope', 'BaseOrdersController'
  , function($rootScope, $scope, BaseOrdersController){
    $rootScope.title = '预订记录';
    $scope.order_type = 'reservation'
    BaseOrdersController.action($scope, function(){})

}]).controller('eatInHallOrdersController', ['$rootScope', '$scope', 'BaseOrdersController'
  , function($rootScope, $scope, BaseOrdersController){
    $rootScope.title = '点单记录';
    $scope.order_type = 'eat_in_hall'
    BaseOrdersController.action($scope, function(){})

}]).controller('fastfoodOrdersController', ['$rootScope', '$scope', 'BaseOrdersController'
  , function($rootScope, $scope, BaseOrdersController){
    $rootScope.title = '快餐记录';
    $scope.order_type = 'fastfood'
    BaseOrdersController.action($scope, function(){})

}]).controller('grouponOrdersController', ['$rootScope', '$scope', 'BaseOrdersController'
  , function($rootScope, $scope, BaseOrdersController){
    $rootScope.title = '团购记录';
    $scope.order_type = 'groupon'
    BaseOrdersController.action($scope, function(){})

}]).controller('rechargeOrdersController', ['$rootScope', '$scope', 'BaseOrdersController'
  , function($rootScope, $scope, BaseOrdersController){
    $rootScope.title = '充值记录';
    $scope.order_type = 'recharge'
    BaseOrdersController.action($scope, function(){})

}]).controller('paymentOrdersController', ['$rootScope', '$scope', 'BaseOrdersController'
  , function($rootScope, $scope, BaseOrdersController){
    $rootScope.title = '买单记录';
    $scope.order_type = 'payment'
    BaseOrdersController.action($scope, function(){})

}]).factory('BaseOrdersController', [
  '$rootScope', '$route', '$routeParams', 'BaseUserOrderService','LoadMoreServiceFactory',
  function ($rootScope, $route, $routeParams, BaseUserOrderService,LoadMoreServiceFactory) {
    function action($scope, callback){

      $scope.filters = [
        {key: 'all',         name: '全部'},
        {key: 'confirmed',   name: '已确认'},
        {key: 'completed',   name: '已完成'},
        {key: 'no-comments', name: '待评价'}
      ]

      var no_comments_orders = function(orders) {
        return orders.filter(function(order) { return order.state == 'completed' && !order.is_commented;});
      };

      var state_orders = function(orders, state){
        return orders.filter(function(order) { return order.state == state});
      }

      $scope.orders = []
      $scope.loadMoreService = LoadMoreServiceFactory.createLoadMoreService({
        id: $route.current.controller,
        onLoadMore: function(page, per_page, timestamp, success){
          BaseUserOrderService.query($scope.order_type, {
            page: page,
            per_page: per_page
          }, function(data){
            if(success) { success(data) }
          });
        },

        update: function(olds){
          $scope.orders = olds;
          $scope.all_orders = olds;
          $scope.confirmed_orders = state_orders(olds, 'confirmed');
          $scope.completed_orders = state_orders(olds, 'completed');
          $scope.no_comments = no_comments_orders(olds);

        }
      });

      $(document).on('scroll', function(){
        if (!$scope.loadMoreService.isLoading()) {
          var scrollTop = $(document.documentElement).scrollTop() || $(document.body).scrollTop();
          if (scrollTop + $(window).height() > $(document).height() - 30) {
            $scope.loadMoreService.loadMore();
          }
        }
      });

      $scope.current_key = 'all';
      $scope.change_filter_tab = function(key){
        $scope.current_key = key;
        var filters = {
          'all': $scope.all_orders,
          'confirmed': $scope.confirmed_orders,
          'completed': $scope.completed_orders,
          'no-comments': $scope.no_comments
        }
        $scope.orders = filters[key];
      }

      $scope.is_finished_state = function(order){
        return ['completed', 'canceled', 'merged'].indexOf(order.state) >= 0;
      }

      $scope.go_detail = function(order){
        $rootScope.go('/branches/' + order.branch_id + '/orders/' + $scope.order_type + '/' + order.id)
      }
    }

    return {
      action: action
    };
}])
