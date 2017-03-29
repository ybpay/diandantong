Ddt.module("ddt.controllers.order", [])
.controller('orderController',
  ['$rootScope', '$scope', '$routeParams', 'UserService', 'BranchService', 'BaseOrderService', 'DeliveryOrderService',
  function($rootScope, $scope, $routeParams, UserService, BranchService, BaseOrderService, DeliveryOrderService){
    $scope.branch_id = $routeParams.branch_id;
    $scope.order_type = $routeParams.order_type;
    $scope.order_id = $routeParams.order_id;

    UserService.get(function(user){
      $scope.user = user;
    })

    BranchService.get({id: $scope.branch_id}, function (branch) {
      $scope.branch = branch;
    });

    BaseOrderService.get_permissions($scope.order_type, $scope.branch_id, $scope.order_id, function(resp){
      $scope.permissions = resp.permissions
    })

    $scope.can_confirm = function(){
      return $scope.permissions && $scope.permissions.indexOf('confirm') != -1 && $scope.order && $scope.order.state == 'pending'
    }

    $scope.can_complete = function(){
      return $scope.permissions && $scope.permissions.indexOf('complete') != -1 && $scope.order && $scope.order.state == 'confirmed'
    }

    $scope.can_hasten = function(){
      return $scope.permissions && $scope.permissions.indexOf('hasten') != -1 && $scope.order && $scope.order.type == 'Ddt::DeliveryOrder' && $scope.order.shipment_state == 'pending'
    }

    $scope.can_start_ship = function(){
      return $scope.permissions && $scope.permissions.indexOf('start_shipment') != -1 && $scope.order && $scope.order.type == 'Ddt::DeliveryOrder' && $scope.order.shipment_state == 'pending'
    }

    $scope.can_finish_ship = function(){
      return $scope.permissions && $scope.permissions.indexOf('finish_shipment') != -1 && $scope.order && $scope.order.type == 'Ddt::DeliveryOrder' && $scope.order.shipment_state == 'shipping'
    }

    $scope.can_assign_to_self = function(){
      return $scope.permissions && $scope.permissions.indexOf('assign_delivery_man') != -1 && $scope.order && $scope.order.type == 'Ddt::DeliveryOrder' && $scope.order.shipment_state == 'pending'
    }

    $scope.can_index_delivery = function(){
      return $scope.permissions && $scope.permissions.indexOf('index_delivery') != -1;
    }

    $scope.confirm = function(){
      if ($scope.can_confirm()) {
        BaseOrderService.confirm($scope.order_type, $scope.branch_id, $scope.order_id, function (resp) {
          $rootScope.alert('已确认该订单')
          $rootScope.reload()
        })
      }
    }

    $scope.complete = function(){
      if ($scope.can_complete()) {
        BaseOrderService.complete($scope.order_type, $scope.branch_id, $scope.order_id, function (resp) {
          $rootScope.alert('已修改订单为完成')
          $rootScope.reload()
        })
      }
    }

    $scope.hasten = function(){
      if ($scope.can_hasten()){
        DeliveryOrderService.hasten($scope.branch_id, $scope.order_id, undefined, function(resp) {
          $rootScope.alert('催单成功')
          $rootScope.reload()
        })
      }
    }

    $scope.start_ship = function(){
      if($scope.can_start_ship()){
        console.log($scope.order_id)
        DeliveryOrderService.start_shipment($scope.branch_id, $scope.order_id, function(resp){
          $rootScope.alert('已标记为配送中')
          $rootScope.reload()
        })
      }
    }

    $scope.finish_ship = function(){
      if($scope.can_finish_ship()){
        DeliveryOrderService.finish_shipment($scope.branch_id, $scope.order_id, function(resp){
          $rootScope.alert('已标记为配送完成')
          $rootScope.reload()
        })
      }
    }

    $scope.assign_to_self = function(){
      if($scope.can_assign_to_self()){
        DeliveryOrderService.assign_to_self($scope.branch_id, $scope.order_id, function(resp){
          $rootScope.alert('成功抢单')
          $rootScope.reload()
        })
      }
    }

    $scope.back = function(){
      $rootScope.go('/delivery_orders')
    }

    $scope.refresh = function(){
      BaseOrderService.get($scope.order_type, $scope.branch_id, $scope.order_id, function (order) {
        $scope.order = order;
        $scope.order.pay_item_state_name = get_order_item('支付状态')
        if($scope.order_type == 'delivery'){ $scope.order.shipment_state_name = get_order_item('配送状态')}
      })
    }

    function get_order_item(item_name){
      if($scope.order){
        var match_item = null;
        angular.forEach($scope.order.order_items, function(item, index){ if(item.name == item_name){ match_item = item } })
        return match_item == null ? null : match_item.value
      }else{
        return null;
      }
    }



    $scope.refresh();

  }])
