Ddt.module("ddt_app.controllers.my.coupons", [])
.controller('couponsController', [
  '$rootScope', '$scope', 'BaseCouponsController',
  function ($rootScope, $scope, BaseCouponsController) {
    $rootScope.title = '优惠劵';
    $scope.coupon_type = 'coupon';

    BaseCouponsController.action($scope, function(){
    })

}]).controller('grouponsController', [
  '$rootScope', '$scope', 'BaseCouponsController',
  function ($rootScope, $scope, BaseCouponsController) {
    $rootScope.title = '团购券';
    $scope.coupon_type = 'groupon';
    BaseCouponsController.action($scope)

}]).controller('vouchersController', [
  '$rootScope', '$scope', 'BaseCouponsController',
  function ($rootScope, $scope, BaseCouponsController) {
    $rootScope.title = '代金券';
    $scope.coupon_type = 'voucher';

    BaseCouponsController.action($scope)
}]).controller('sharableCouponsController', [
  '$rootScope', '$scope', 'SharableCouponService',
  function($rootScope, $scope, SharableCouponService){

    $rootScope.title = '商家红包';

    SharableCouponService.query(function(sharable_coupons){
      $scope.sharable_coupons = sharable_coupons
    })

    $scope.go_show = function(sharable_coupon){
      $rootScope.go('/user/sharable_coupons/' + sharable_coupon.id)
    }

}]).factory('BaseCouponsController', [
'$rootScope', '$route', '$routeParams', 'BaseUserCouponService', 'LoadMoreServiceFactory',
function ($rootScope, $route, $routeParams, BaseUserCouponService, LoadMoreServiceFactory) {

  function action($scope, callback) {

    $scope.tab = 'available';
    $scope.tabs = ['available', 'applied', 'expired', 'refund'];

    $scope.change_filter_tab = function(tab){
      $scope.tab = tab
      $scope.base_coupons = $scope[tab + '_base_coupons']
      console.log(tab)
    }

    angular.forEach($scope.tabs, function(tab){
      $scope[tab + '_loadMoreService'] = LoadMoreServiceFactory.createLoadMoreService({
        id: $scope.coupon_type + '_load_more_'+tab,
        onLoadMore: function(page, per_page, timestamp, success){
          BaseUserCouponService.query($scope.coupon_type, {
            page: page,
            per_page: per_page,
            state: tab,
          }, function(data){
            if(success) { success(data) }
          });
        },

        update: function(base_coupons){
          $scope[tab + '_base_coupons'] = base_coupons;
          $scope.change_filter_tab($scope.tab);
        }
      })
    })

    $(document).on('scroll', function(){
      var service_name = $scope.tab + '_loadMoreService'
      if (!$scope[service_name].isLoading()) {
        var scrollTop = $(document.documentElement).scrollTop() || $(document.body).scrollTop();
        if (scrollTop + $(window).height() > $(document).height() - 30) {
          $scope[service_name].loadMore();
        }
      }
    });

    $scope.can_exchange_code = function(base_coupon){
      return !base_coupon.expired && !base_coupon.applied_at && !base_coupon.refund_at && base_coupon.exchange_code_state == 'pending'
    }

    $scope.go_exchange_code = function(base_coupon){
      $rootScope.go('/exchange_codes/' + base_coupon.exchange_code_id)
    }

    $scope.go_show = function(base_coupon){
      $rootScope.go("/user/" + $scope.coupon_type + "s/" + base_coupon.id)
    }


  }

  return {
    action: action
  };
}]);
