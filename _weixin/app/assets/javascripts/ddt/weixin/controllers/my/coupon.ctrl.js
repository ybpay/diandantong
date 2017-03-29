Ddt.module("ddt_app.controllers.coupon", [])
.controller('couponController', [
  '$rootScope', '$scope', 'BaseCouponController',
  function ($rootScope, $scope, BaseCouponController) {
    $rootScope.title = '优惠劵详情';
    $scope.type_name = '优惠券';
    $scope.coupon_type = 'coupon';

    BaseCouponController.action($scope)

}]).controller('grouponController', [
  '$rootScope', '$scope', 'BaseCouponController',
  function ($rootScope, $scope, BaseCouponController) {
    $rootScope.title = '团购券详情';
    $scope.type_name = '团购券';
    $scope.coupon_type = 'groupon';
    BaseCouponController.action($scope)

}]).controller('voucherController', [
  '$rootScope', '$scope', 'BaseCouponController',
  function ($rootScope, $scope, BaseCouponController) {
    $rootScope.title = '代金券详情';
    $scope.type_name = '代金券';
    $scope.coupon_type = 'voucher';

    BaseCouponController.action($scope)

}]).controller('sharableCouponController', [
  '$rootScope', '$scope', '$routeParams', 'SharableCouponService', 'ShopService',
  function ($rootScope, $scope, $routeParams, SharableCouponService, ShopService) {
    $rootScope.title = '优惠券红包详情';
    $rootScope.show_share_menu();
    $scope.sharable_coupon_id = $routeParams.sharable_coupon_id
    SharableCouponService.get($scope.sharable_coupon_id, function(sharable_coupon){
      $scope.sharable_coupon = sharable_coupon
    });

    ShopService.get(function(shop){
      $scope.shop = shop;
    });

    $rootScope.shareRecordTrigger = {
      triggerBeforeCreateRecord: function(resp, wxShareConfig){
        wxShareConfig.title = "点击领取优惠券红包 来自" + $scope.shop.name;
        wxShareConfig.desc = "我在" + $scope.shop.name + "上抢到了不少红包，送你一个, 下单可直接抵扣!";
        wxShareConfig.imgUrl = window.location.origin + "/images/ddt/hongbao.jpg";
        wxShareConfig.link = UrlParser.change_parameter(wxShareConfig.link, '_ng_path', "/sharable_coupons/" + $routeParams.sharable_coupon_id);
      }
    };

  }]).factory('BaseCouponController', [
'$rootScope', '$routeParams', 'BaseUserCouponService',
function ($rootScope, $routeParams, BaseUserCouponService) {

  function action($scope, callback) {
    $scope.base_coupon_id = $routeParams.base_coupon_id;
    $scope.cannot_exchange_code_title = '';
    BaseUserCouponService.get($scope.coupon_type, $scope.base_coupon_id, function(base_coupon){
      console.log(base_coupon)
      $scope.base_coupon = base_coupon;
      set_state_name($scope.base_coupon)
    });

    function set_state_name(base_coupon){
      if(base_coupon.expired){
        $scope.cannot_exchange_code_title = "已过期"
        return
      }
      if(base_coupon.applied_at){
        $scope.cannot_exchange_code_title = '已兑换'
        return
      }
      if(base_coupon.refund_at){
        $scope.cannot_exchange_code_title = '已退款'
        return
      }
      if(base_coupon.applying_refund){
        $scope.cannot_exchange_code_title = '申请退款中'
        return
      }
      $scope.cannot_exchange_code_title = base_coupon.exchange_code_state_name
    }

    $scope.can_exchange_code = function(){
      var base_coupon = $scope.base_coupon
      return base_coupon && !base_coupon.expired && !base_coupon.applied_at && !base_coupon.refund_at && !base_coupon.applying_refund && base_coupon.exchange_code_state == 'pending'
    };

    $scope.can_apply_refund = function(){
      return $scope.base_coupon && $scope.base_coupon.can_apply_refund;
    }

    $scope.apply_refund = function(){
      $rootScope.confirm('请再次确认', '确认要申请退款？', function(){
        BaseUserCouponService.apply_refund($scope.coupon_type, $scope.base_coupon_id, function(base_coupon){
          $scope.base_coupon = base_coupon;
          set_state_name($scope.base_coupon)
        })
      })
    }

    $scope.cancel_refund = function(){
      $rootScope.confirm('请再次确认', '确认要取消退款申请？', function(){
        BaseUserCouponService.cancel_apply_refund($scope.coupon_type, $scope.base_coupon_id, function(base_coupon){
          $scope.base_coupon = base_coupon;
          set_state_name($scope.base_coupon)
        })
      })
    }

    $scope.is_applying_refund = function(){
      return $scope.base_coupon && $scope.base_coupon.applying_refund
    }

    $scope.go_exchange_code = function(){
      var base_coupon = $scope.base_coupon
      $rootScope.go('/exchange_codes/' + base_coupon.exchange_code_id)
    };

  };

  return {
    action: action
  };
}]);
