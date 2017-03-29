Ddt.controller('tuansController', [
  '$rootScope', '$scope', '$routeParams', 'TuanService', 'ShopService', 'QueryService', 'ZoneService',
  function ($rootScope, $scope, $routeParams, TuanService, ShopService, QueryService, ZoneService) {
    $rootScope.title = "猜你喜欢"
    $scope.tuans = []
    $scope.branch_type_arrays = [];
    ShopService.get(function(shop){
      $scope.shop = shop
      $scope.branch_type_arrays = [];
      var branch_types = angular.copy($scope.shop.branch_types,[]);
      branch_types.unshift({
        id: 0,
        image: null,
        bg_color: '#72C02C',
        icon: 'fa-globe',
        name: '全部类型'
      });
      var size = 4;
      for (var i=0; i< branch_types.length; i+=size) {
        $scope.branch_type_arrays.push(branch_types.slice(i,i+size));
      }
    });

    var query = QueryService.getCombineQuery();
    TuanService.query(query, function(tuans){
      $scope.tuans = tuans;
    });

    $scope.current_zone_id = parseInt(query['query[in_zone]'])||0;
    ZoneService.query({hierarchy: true}, function(data){
      $scope.zones = data;
      if ($scope.current_zone_id) {
        var found_zone_name = false;
        angular.forEach($scope.zones, function (zone) {
          if (!found_zone_name) {
            if (zone.id == $scope.current_zone_id) {
              $scope.zone_name = zone.name;
              found_zone_name = true;
              return;
            }
            angular.forEach(zone.sub_zones, arguments.callee);
          }
        });
      }
      $scope.zones.unshift({
        id: 0,
        name: '全部区域',
        parent_zone_id: null
      })
    });

    $scope.filter_by_branch_type = function(branch_type_id){
      if (branch_type_id == 0){
        delete query['query[branch_branch_type_id_eq]']
      }else {
        query['query[branch_branch_type_id_eq]'] = branch_type_id;
      }
      $rootScope.go('/tuans?' + QueryService.buildQueryString(query));
    };

    $scope.filter_by_zone = function(zone_id){
      if (zone_id == 0){
        delete query['query[in_zone]']
      }else {
        query['query[in_zone]'] = zone_id;
      }
      if(zone_id == $scope.current_zone_id){
        $scope.active_select_zone = !$scope.active_select_zone;
      }
      $rootScope.go('/tuans?' + QueryService.buildQueryString(query));
    }

  }]).controller('tuanController', [
  '$rootScope', '$scope', '$routeParams', 'TuanService', 'GrouponCartService', 'ShopService', 'DdtConst',
  function($rootScope, $scope, $routeParams, TuanService, GrouponCartService, ShopService, DdtConst){
    $scope.tuan_id = $routeParams.tuan_id;

    TuanService.get($scope.tuan_id, function(tuan){
      $scope.tuan = tuan
    });

    $scope.add_tuan = function(){
      GrouponCartService.add_tuan($rootScope.current_shop.abstract_branch_id, $scope.tuan.id, function(cart){
        $rootScope.go("/branches/" + $rootScope.current_shop.abstract_branch_id + '/orders/groupon/new')
      })
    };

    ShopService.get(function(shop) {
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
        wxShareConfig.title = $scope.tuan.name + " 来自 " + $scope.shop.name;
        wxShareConfig.desc = "我在" + $scope.shop.name + "发现了相当优惠的团购，一起来团吧";
        wxShareConfig.imgUrl = avatar;
      }
    };
  }
]);



