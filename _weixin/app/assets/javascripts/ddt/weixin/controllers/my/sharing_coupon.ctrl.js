"use strict"

Ddt.controller('sharingCouponController', [
  '$rootScope', '$scope', '$routeParams', 'SharingCouponService', 'ShopService',
  function ($rootScope, $scope, $routeParams, SharingCouponService, ShopService) {
    $rootScope.title = '领取优惠券';
    $scope.sharable_coupon_id = $routeParams.sharable_coupon_id;

    SharingCouponService.get($scope.sharable_coupon_id, function(sharable_coupon){
      $scope.sharable_coupon = sharable_coupon
    });

    function can_submit(){
      return !$rootScope.is_submiting
    }

    $scope.receive = function(){
      if(can_submit()){
        $rootScope.is_submiting = true
        SharingCouponService.receive($scope.sharable_coupon_id, function(resp){
          if(resp.status === 'ok'){
            $rootScope.is_submiting = false
            $scope.sharable_coupon.receive_count += 1
            $scope.coupon_received = true;
            $scope.$emit("events:success_info", "恭喜，您成功抢到了一张优惠券(" + $scope.sharable_coupon.coupon_version_name + ")，可用于在"+$rootScope.current_shop.name+"进行消费抵扣哦...");
          }else{
            $rootScope.is_submiting = false
            $scope.coupon_received = false;
            $scope.coupon_received_reason = resp.errors;
          }
        })
      }
    };

    $scope.go_coupon = function(){
      $rootScope.go("/user/coupons")
    }
  }]);
