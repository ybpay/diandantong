"use strict"

Ddt.controller('myController', [
  '$rootScope', '$scope', '$location','$routeParams', 'UserService', 'ShopService','VipInfoSettingService',
  function($rootScope, $scope, $location, $routeParams, UserService, ShopService, VipInfoSettingService){

    $rootScope.title = '个人中心'


    UserService.get(function(user){
      $scope.user = user;
    });
    ShopService.get(function(shop){
      $scope.shop = shop;
    })
    VipInfoSettingService.get({}).$promise.then(function(setting){
      $scope.setting = setting
     var btns = Base.newBtns($location);
     if($rootScope.has_feature('model_vip_info') && setting.show_vippay_module){
       btns.push({
        img: '/images/ddt/my/pay_code.png',
        label: "会员付款码",
        func: function(){
          if($scope.user.is_vip){
            $location.path("/user/scan-code");
          }else {
            $scope.$emit("events:receive_errors", "您需要开通会员才能开启会员付款码功能！")
          }
        }
       });
     }

     if($rootScope.has_feature('model_vip_info') && setting.show_rechange_module){
       btns.push({
        img: '/images/ddt/my/vip_recharge.png',
        label: "会员充值",
        func: function(){
          if($scope.user.is_vip){
            $rootScope.go_page('cart', "/branches/" +$scope.shop.abstract_branch_id+ "/orders/recharge/new");
          }else {
            $scope.$emit("events:receive_errors", "您需要成为会员才能进行会员充值功能！")
          }
        }
       });
     }

     if(setting.show_order_module){
       btns.push({
        img: '/images/ddt/my/orders.png',
        label: "订单中心",
        func: function(){
          $rootScope.go_page('order', '/orders/nav')
        }
       });
     }

     if($rootScope.has_feature('base_promotion') && setting.show_coupon_module){
       btns.push({
        img: '/images/ddt/my/coupons.png',
        label: "我的卡券",
        href: '/user/coupon_nav'
       });
     }

     if($rootScope.has_feature('base_promotion') && setting.show_credits_exchange_module){
       btns.push({
        img: '/images/ddt/my/credit.png',
        label: "积分兑换",
        href: '/user/exchange/nav'
       });
     }

     if($rootScope.has_feature('wechat_api') && setting.show_sign_record_module){
       btns.push({
        img: '/images/ddt/my/sign.png',
        label: "每日签到",
        href: '/sign_records'
       });
     }

     if($rootScope.has_feature('wechat_api') && setting.show_share_record_module){
       btns.push({
        img: '/images/ddt/my/share.png',
        label: "分享纪录",
        href: '/wechat_share_records'
       });
     }

     if($rootScope.has_feature('wechat_api') && setting.show_address_module){
       btns.push({
        img: '/images/ddt/my/address.png',
        label: "收货地址",
        func: function(){
          $rootScope.go_page('cart', '/addresses');
        }
       });
     }

     if($rootScope.has_feature('wechat_api') && setting.show_collect_module){
       btns.push({
        img: '/images/ddt/my/favorite.png',
        label: "我的收藏",
        func: function(){
          $rootScope.go_page('main', '/favorite_branches')
        }
       });
     }

     if($rootScope.has_feature('model_vip_info') && !$scope.user.headimgurl){
       btns.push({
        img: '/images/ddt/my/wechat_pay.png',
        label: "绑定微信",
        func: function(){
          $location.url($rootScope.oauth_user_info_url);
        }
       })
     }

     if($rootScope.has_feature('model_vip_info')){
       btns.push({
        img: '/images/ddt/my/settings.png',
        label: "用户设置",
        func: function(){
          $rootScope.go('/user/settings')
        }
       });
     }
     $scope.item_groups = btns.group();
    })


}]).controller('settingsController', ['$scope', '$rootScope', 'UserService', function($scope, $rootScope, UserService){
  $rootScope.title = "个人设置";
  UserService.get(function(user){
    $scope.user = user;
  });
}])
