"use strict"
Ddt.module("ddt_app.controllers.shop", [])
.controller('shopController', [
  '$rootScope', '$scope', '$location', 'ShopService', 'PromotionService', 'GeolocationService','TuanService',
  function($rootScope, $scope, $location, ShopService, PromotionService, GeolocationService, TuanService){
    $scope.shop = null
    $scope.custom_weixin_info = null
    $scope.hot_link_groups = []
    $scope.usable_links = []
    $scope.promotions = []
    $scope.hot_links = []
    $scope.nav_group_size = 3;

    ShopService.get(function(shop){
      $scope.shop = shop;
      $scope.custom_weixin_info = shop.custom_weixin_info;
      var hot_links    = shop.custom_weixin_info.home_hot_links || [];

      if($scope.shop.is_single && $scope.shop.single_branch_links){
        hot_links = hot_links.concat($scope.shop.single_branch_links);
      }
      $scope.hot_links = $scope.hot_links.concat(hot_links);
      $scope.hot_link_groups = group_in(hot_links, 8, true);
      angular.forEach($scope.hot_link_groups, function(group, index){
        $scope.hot_link_groups[index] = group_in(group, 4)
      })
      if('classic' == $scope.custom_weixin_info.layout_type){
        $scope.usable_link_groups = group_in(shop.custom_weixin_info.home_usable_links, 2);
      }
    });

    $scope.click_tab_slider = function(key){
      var link = key;
      if(link.indexOf('eat_in_hall') >= 0){
        $rootScope.toggle_show_eat_in_hall_select()
      }else{
        $rootScope.go(link)
      }
    }

    $scope.relocation = function(){
      $scope.formatted_address = '定位中';
      GeolocationService.get_current_position(function(position_data){
        $scope.formatted_address = position_data.address.formatted_address;
      })
    }

    $scope.relocation();

    var color_classes = ['orange', 'red', 'yellow', 'blue', 'green'];
    $scope.color_class = function(link){
      var index = $scope.custom_weixin_info.home_usable_links.indexOf(link);
      return color_classes[index%5];
    }

    $scope.is_classic_layout = function(){
      return $scope.custom_weixin_info.layout_type === 'classic';
    }

    PromotionService.show_on_index(function(promotions){
      $scope.promotions = promotions;
    });

    TuanService.show_on_index(function(tuans){
      $scope.tuans = tuans;
    });

    $scope.click_slider = function(s){
      console.log(s);
    }
}])
