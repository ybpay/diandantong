WebposModules.add_cell('coupon_choose');
angular.module('webpos.cells.coupon_choose', []).
  controller('couponChooseCell',
    ['$rootScope', '$scope', '$routeParams', 'CouponService',
    function($rootScope, $scope, $routeParams, CouponService){

      $scope.branch_id = $routeParams.branch_id;


      var clear_bind_vip_info_listener = $scope.$on("event:bind_vip_info", function(event, vip_info){
        $scope.vip_info = vip_info;
        CouponService.available($scope.branch_id, $scope.vip_info.user_id, function(coupons){
          $scope.coupons = coupons;
          if($scope.coupons.length > 0){
            $scope.active_coupon = $scope.coupons[0]
          }
        });
      })
      $scope.$on("$destroy", function(){
        clear_bind_vip_info_listener()
      })

      $scope.choose_coupon = function(coupon) {
        $scope.active_coupon = coupon
      }

      $scope.confirm = function(){
        $scope.$emit("event:choose_coupon", $scope.active_coupon);
      }

      $rootScope.$broadcast("event:get_bind_vip_info", "");

    }]);