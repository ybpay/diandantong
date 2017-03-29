Ddt.module("ddt.controllers.order_success", [])
.controller('orderSuccessController', [
  '$rootScope', '$scope', '$routeParams', '$timeout', 'BranchService', 'BaseOrderService',
  function($rootScope, $scope, $routeParams, $timeout, BranchService, BaseOrderService){
    $rootScope.title = '订单已提交';
    $scope.order_type = $routeParams.order_type;
    $scope.branch_id = $routeParams.branch_id;
    $scope.order_id = $routeParams.order_id;
    $scope.is_pay_before_mode = false;
    $scope.is_ban_selfpay = false;
    $scope.hide_buttons = true;
    $scope.is_eat_in_hall = $scope.order_type == "eat_in_hall"

    function delay_go_page(page, path, with_delay){
      if(with_delay){
        $timeout(function(){
          $rootScope.go_page(page, path)
        }, 3000)
      }else{
        $rootScope.go_page(page, path)
      }
    }

    $scope.hint = '';
    $scope.desc = ''
    $scope.can_confirm = false;
    $scope.can_back = false;
    BranchService.get({id: $scope.branch_id}, function (branch) {
      $scope.branch = branch;
      BaseOrderService.get($scope.order_type, $scope.branch_id, $scope.order_id, function (order) {
        console.log(order)
        $scope.order = order;
        $scope.is_ban_selfpay = ($scope.is_eat_in_hall && $scope.order.ban_selfpay)
        $scope.is_pay_before_mode = ($scope.is_eat_in_hall && ($scope.branch.eat_in_hall_mode == "pay_before"));
        if($scope.is_eat_in_hall && !$scope.is_pay_before_mode){
          $scope.hint = '操作成功，订单已提交至厨房，请耐心等待大厨们为您准备的美食...'
          $scope.desc =  '3秒后自动跳转至订单, 如未跳转请点击下方按钮';
          $scope.can_confirm = true;
          $scope.confirm_label = '点击跳转';
          $scope.confirm = function(){
            delay_go_page('order', '/branches/' + $scope.branch_id + '/orders/eat_in_hall/' + $scope.order_id, false)
          }
          delay_go_page('order', '/branches/' + $scope.branch_id + '/orders/eat_in_hall/' + $scope.order_id, true)
          return;
        }
        $scope.can_pay_online = function () {
          // FIXME $scope.permissions.indexOf('pay_online') != -1
          return $scope.order && $scope.order.state != 'canceled' && $scope.order.pay_item_state == 'unpaid' && ['alipay', 'wechatpay', 'baidupay'].indexOf($scope.order.pay_method) >= 0;
        };

        $scope.pay_online = function(){
          delay_go_page('order', '/branches/' + $scope.branch_id + '/orders/' + $scope.order_type + '/' + $scope.order_id +'/pay_online')
        }

        $scope.hide_buttons = false;
         if(!$scope.can_pay_online()){
           if($scope.order_type=='groupon'){
             $scope.hint = '操作成功，订单已提交!'
          }else
          $scope.hint = '操作成功，订单已提交至厨房，请耐心等待大厨们为您准备的美食'
        }
        if($scope.is_ban_selfpay){
          $scope.hint = '操作成功，订单已提交至厨房，请耐心等待大厨们为您准备的美食'
          $scope.can_confirm = true;
          $scope.confirm_label  = '查看订单'
          $scope.can_back = true;
          $scope.back_label = '返回门店';
          $scope.back = function(){
            $scope.go_page('main', '/branches/'+$scope.branch_id)
          }
        }else{
          if($scope.can_pay_online()){
            if($scope.order_type=='groupon'){
             $scope.hint = '操作成功，订单已提交!'
           }else{
              $scope.hint = '订单已提交！支付后厨师就可以为你备餐啦...'}
            $scope.desc =  '3秒后自动跳转支付页面, 如未跳转请点击下方按钮'
            $scope.can_confirm = true;
            $scope.confirm = $scope.pay_online;
            $scope.confirm_label = '点击跳转'
          }
        }

        if(!$scope.hide_buttons && !$scope.can_pay_online()){
          $scope.can_confirm = true;
          $scope.confirm_label = '查看订单';
          if(!$scope.can_pay_online()){
            $scope.can_back = true;
            $scope.back_label = '返回门店';
            $scope.back = function(){
              $scope.go_page('main', '/branches/'+$scope.branch_id)
            }
          }
        }

        if(!$scope.hide_buttons && $scope.is_ban_selfpay && $scope.can_pay_online()){
          $scope.can_confirm = true;
        }

        if(!$scope.is_ban_selfpay && $scope.can_pay_online()){
          delay_go_page('order', '/branches/' + $scope.branch_id + '/orders/' + $scope.order_type + '/' + $scope.order_id +'/pay_online', true)
          return;
        }

        $scope.confirm = function(){ $rootScope.go_page('order', '/branches/' + $scope.branch_id + '/orders/'+$scope.order_type+'/' + $scope.order_id)}

      })
    });
  }]);
