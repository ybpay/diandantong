"use strict"
Ddt
  .controller('promotionsController', [
    '$rootScope', '$scope', 'PromotionService',
    function($rootScope, $scope, PromotionService){
      $rootScope.title = '优惠促销';
      PromotionService.query(function(promotions){
        $scope.promotions = promotions;
      })
}]).controller('promotionController', [
    '$rootScope', '$scope', '$routeParams', 'PromotionService', 'ShopService', 'DdtConst',
    function($rootScope, $scope, $routeParams, PromotionService, ShopService, DdtConst){
      $scope.promotion_id = $routeParams.promotion_id
      PromotionService.get($scope.promotion_id, function(promotion){
        $scope.promotion = promotion;
        $rootScope.title = promotion.title;
      });
      ShopService.get(function(shop){
        $scope.shop = shop;
      });
      $rootScope.shareRecordTrigger = {
        triggerBeforeCreateRecord: function(resp, wxShareConfig){
          var avatar = DDBUtil.findFirstAvatar();
          if (avatar.length > 0){
            avatar = avatar.attr("src");
          }else{
            avatar = DDBUtil.makeAssetUrl($scope.shop.image, DdtConst, true);
          }
          wxShareConfig.title = $scope.promotion.name + " 来自 " + $scope.shop.name;
          wxShareConfig.desc = $scope.promotion.description;
          wxShareConfig.imgUrl = avatar;
        }
      };
}]);