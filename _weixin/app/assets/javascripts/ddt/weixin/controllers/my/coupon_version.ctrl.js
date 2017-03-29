Ddt.controller('CouponVersionController',
  ['$rootScope', '$scope', '$routeParams', 'UserService', 'CouponVersionService',
  function($rootScope, $scope, $routeParams, UserService, CouponVersionService){

    $scope.version_id = $routeParams.id;

    UserService.get(function(user){
      $scope.user = user;
    })

    CouponVersionService.get($scope.version_id, function(coupon_version){
      $scope.coupon_version = coupon_version;
      $scope.coupon_version.exchange_num = 0;
      console.log($scope.coupon_version)
    })

    $scope.go_exchange = function(){
      $rootScope.go('/user/exchange/coupon_versions/'+$scope.version_id+'/exchange')
    }

    $scope.plus = function(){
      if($scope.can_plus()){
        $scope.coupon_version.exchange_num += 1;
      }else{
        $scope.$emit("events:receive_errors", plus_errors());
      }
    }
    $scope.minus = function(){
      if($scope.can_minus()){
        $scope.coupon_version.exchange_num -=1;
      }
    }
    $scope.can_minus = function(){
      return $scope.coupon_version.exchange_num > 0;
    }

    function plus_errors(){
      var errors = [];
      if(!$scope.coupon_version){
        errors.push("优惠券不存在");
      }
      if(!$scope.coupon_version.can_exchange){
        errors.push("优惠券已不允许兑换");
      }
      if($scope.coupon_version.exchange_num >= $scope.coupon_version.max_count_each_user){
        errors.push("该优惠券已经被兑换光了");
      }
      if($scope.user.credits_wallet < $scope.coupon_version.exchange_num * $scope.coupon_version.credit_count){
        errors.push("积分不足");
      }
      return errors;
    }

    $scope.can_plus = function(){
      return $scope.coupon_version && $scope.coupon_version.can_exchange && $scope.coupon_version.exchange_num < $scope.coupon_version.max_count_each_user && $scope.user.credits_wallet >= ($scope.coupon_version.exchange_num + 1) * $scope.coupon_version.credit_count
    }

    $scope.exchange = function(){
      if($scope.coupon_version.exchange_num > 0){
        CouponVersionService.exchange($scope.version_id, $scope.coupon_version.exchange_num, '积分兑换优惠券: '+$scope.coupon_version.name, function(){
          UserService.refresh(function(){})
          $rootScope.go('/user/exchange/success')
        })
      }else{
        $rootScope.alert('您未选择兑换')
      }
    }


  }])
