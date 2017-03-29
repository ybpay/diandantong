Ddt.module("ddt.controllers.delivery_orders", [])
.controller('deliveryOrdersController',
  ['$rootScope', '$scope', '$routeParams', 'UserService', 'DeliverymanOrdersService', 'BranchService','RefreshService','DeliveryOrderService','BaseOrderService',
  function($rootScope, $scope, $routeParams, UserService, DeliverymanOrdersService, BranchService,RefreshService,DeliveryOrderService,BaseOrderService){
    $scope.tabs = [
      {name: '待抢单', key: 'unassign'},
      {name: '待取餐', key: 'pending'},
      {name: '配送中', key: 'shipping'},
      {name: '已配送', key: 'shipped'},

    ]

     UserService.get(function(user){
      $scope.user = user;
    })

     $scope.unassign_count = 0;



    $scope.change_tab = function(tab){
      if( tab.key != $scope.active_key ){
        $scope.active_key = tab.key;
        if( tab.key != 'unassign' ){
          $scope.load_orders({assign: true});

        }else{
          $scope.load_orders({})
        }
      }
    }

    $scope.show_order = function(order){
      $rootScope.go('/branches/'+order.branch_id+'/orders/delivery/'+order.id)
    }

    $scope.load_orders = function(options){
      $scope.orders = [];
      DeliverymanOrdersService.query(options, function(orders){
        $scope.all_orders = orders;
        $scope.orders = filter_orders(orders);
      })
    }

    function filter_orders(orders){
      var os = []
      if('unassign' === $scope.active_key){
        $scope.unassign_count = orders.length
        return orders;
      }

      if(['pending', 'shipping', 'shipped'].indexOf($scope.active_key) != -1){
        var os = []
        angular.forEach(orders, function(order){
          if(order.deliveryman_id != null && order.shipment_state == $scope.active_key){
            os.push(order)
          }
        })
        return os;
      }
      return os;
    }

     $scope.assign_to_self = function(order){
      // if($scope.can_assign_to_self()){
      $rootScope.confirm('确认', '确认抢单', function(){
        DeliveryOrderService.assign_to_self(order.branch_id, order.id, function(resp){
          $rootScope.alert('成功抢单')
          $rootScope.reload()
        })
       })
    }
     $scope.start_ship = function(order){
      // if($scope.can_start_ship()){
      $rootScope.confirm('确认', '确认配送', function(){
        console.log($scope.order_id)
        DeliveryOrderService.start_shipment(order.branch_id, order.id, function(resp){
          $rootScope.alert('已标记为配送中')
          $rootScope.reload()
        })
      })
      // }
    }

   $scope.finish_ship = function(order){
      // if($scope.can_finish_ship()){
      $rootScope.confirm('确认', '确认完成', function(){
        DeliveryOrderService.finish_shipment(order.branch_id, order.id, function(resp){
          $rootScope.alert('已标记为配送完成')
          $rootScope.reload()
        })
      })
      // }
    }

    function fetch_new(){
      $scope.load_orders({fetch: true, fetch_new: true})
    }

    /* init */
    $scope.change_tab($scope.tabs[1])
    UserService.get(function(user){
      $scope.user = user;
    })




  }]);
