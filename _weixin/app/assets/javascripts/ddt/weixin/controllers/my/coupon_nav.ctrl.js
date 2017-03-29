"use strict"
Ddt.controller('couponNavController', [
  '$rootScope', '$scope', '$location','UserService', 'ShopService', 'CouponService',
  function($rootScope, $scope, $location, UserService, ShopService, CouponService){

  $rootScope.title = '卡包';

   UserService.get(function(user){
    $scope.user = user;
  });
   ShopService.get(function(shop){
    $scope.shop = shop;
   })
   CouponService.status(function(coupon_status){
    $scope.coupon_status = coupon_status;
   })

   var btns = Base.newBtns($location);
   btns.push({
    img: '/images/ddt/my/coupon.png',
    label: "优惠券",
    href: '/user/coupons'
   });

   btns.push({
    img: '/images/ddt/my/voucher.png',
    label: "代金券",
    href: '/user/vouchers'
   });

   btns.push({
    img: '/images/ddt/my/groupon.png',
    label: "团购券",
    href: '/user/groupons'
   });

   // btns.push({
   //  img: '/images/ddt/my/hongbao.png',
   //  label: "商家红包",
   //  href: '/user/sharable_coupons'
   // });

   $scope.item_groups = btns.group();



}])
