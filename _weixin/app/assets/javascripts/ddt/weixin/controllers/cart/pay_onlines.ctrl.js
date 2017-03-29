"use strict"

Ddt.module("ddt_app.controllers.pay_online", []).controller('newPayOnlineController', [
  '$rootScope', '$scope', '$routeParams', 'ShopService','UserService','BranchService', 'PaymentOrderService',
  function($rootScope, $scope, $routeParams, ShopService, UserService, BranchService, PaymentOrderService){
    $scope.branch_id = $routeParams.branch_id
    $scope.shop = null
    $scope.pay_methods = []
    BranchService.get({id: $scope.branch_id}, function(branch){
      $scope.branch = branch;
      $rootScope.title = branch.name;
      // pay_methods
      $scope.pay_method_setting = branch.pay_method_setting['payment'];
      $scope.pay_methods = ShopService.get_pay_methods($scope.pay_method_setting)
      $scope.item_groups = group_in($scope.pay_methods, 4);
      // $scope.current_pay_method = $scope.pay_methods[0];
    });

    ShopService.get(function(shop){
      $scope.shop = shop
    })

    UserService.get(function(user){
      $scope.user = user
    })

    $scope.choose_payment_method = function(payment_method){
      if(payment_method.value === 'vip_card_pay'){
        if($scope.user.is_vip){
          $rootScope.password_modal.open(function(){
            $scope.current_pay_method = payment_method;
          })
        }else{
          $rootScope.$emit("events:receive_errors", "对不起， 您还不是会员, 如想申请会员可在用户中心下的会员卡中申请");
        }
      }else{
        $scope.current_pay_method = payment_method;
      }
    }

    $scope.can_submit = function(){
      return $scope.current_pay_method && ($scope.amount > 0);
    }

    $scope.submit = function(){
      if($scope.can_submit()){
        PaymentOrderService.create($scope.branch_id, {
          amount: $scope.amount,
          payment_method: $scope.current_pay_method.value
        }, function(resp){
          if(resp.order && resp.order.id){
            $rootScope.go('/branches/' + $scope.branch_id + '/order_success/'+ resp.order.id + '/payment', false);
          }
        })
      }
    }

}])
