WebposModules.add_controller('branch_eat_in_hall')
angular.module('webpos.controllers.branch_eat_in_hall', []).
  controller('branchEatInHallController',
    ['$rootScope','$scope','$routeParams','BranchService','$timeout', 'TableZoneService', 'ProductService',
    function($rootScope, $scope,$routeParams, BranchService, $timeout, TableZoneService, ProductService){
      $rootScope.navigation_msg = "";
      $scope.branch_id = $routeParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
      })
      
      ProductService.queryAll($scope.branch_id, true).then(function(){})

      $scope.action = 'init' // ['init', 'change_table', 'merge_table', 'append_itemable', 'change_vip_info']
      $scope.back = function(){
        if($scope.action != 'init'){
          $scope.$broadcast("event:back")
        }else{
          $rootScope.back()
        }
      }

      
      
      $scope.$on('event:choose_table:reset', function(event) {
        $scope.$broadcast("event:choose_table:" + $scope.action + ":reset")
      })

      var clear_choose_table_listener = $scope.$on('event:choose_table', function(event, table) {
        init_ban_product_ids(table)
        $scope.$broadcast("event:choose_table:" + $scope.action, table)
      })

      var clear_settle_table_listener = $scope.$on('event:settle_table', function(event, table){
        $scope.$broadcast("event:choose_table:settle", table)
      })

      var clear_choose_itemable_listener = $scope.$on('event:choose_itemable', function(event, itemable){
        $scope.$broadcast("event:choose_itemable:" + $scope.action, itemable)
      })

      var clear_choose_vip_info_listener = $scope.$on('event:choose_vip_info', function(event, vip_info){
        $scope.$broadcast("event:choose_vip_info:" + $scope.action, vip_info)
      })

      var clear_choose_coupon_listener = $scope.$on('event:choose_coupon', function(event, coupon){
        $scope.$broadcast("event:choose_coupon:" + $scope.action, coupon)
      })

      var clear_choose_order_listener = $scope.$on('event:choose_order', function(event, order){
        $scope.$broadcast("event:choose_order:" + $scope.action, order)
      })

      var clear_table_subtract_itemable_listener = $scope.$on("event:table:subtract_itemable:order", function(event, order){
        $scope.$broadcast("event:subtract_itemable:order", order)
      })

      var clear_table_move_itemable_listener = $scope.$on("event:table:move_itemable:order", function(event, order){
        $scope.$broadcast("event:move_itemable:order", order)
      })

      var clear_subtract_itemable_listener = $scope.$on("event:subtract_itemable:success", function(event){
        $scope.$broadcast("event:table:subtract_itemable:success")
      })

      var clear_move_itemable_listener = $scope.$on("event:move_itemable:success", function(event){
        $scope.$broadcast("event:table:move_itemable:success")
      })

      function init_ban_product_ids(table){
        TableZoneService.get_ban_product_ids($scope.branch_id, table.table_zone_id, function(ban_product_ids){
          $scope.ban_product_ids = ban_product_ids;
        })
      }

      $scope.show_tables = function(){ return ['init', 'change_table', 'merge_table'].indexOf($scope.action) !== -1 }
      $scope.show_products = function(){ return $scope.action === 'append_itemable'}
      $scope.show_vip_infos = function(){ return $scope.action === 'change_vip_info'}
      $scope.show_reservation_orders = function(){ return $scope.action === 'bind_reservation_order'}
      $scope.show_coupons = function(){ return $scope.action == "apply_coupon"}
      $scope.show_subtractables = function() { return $scope.action === "subtract_itemable"; };
      $scope.show_moveables = function() { return $scope.action === "move_itemable"; };

      var clear_table_action_listener = $scope.$on('event:table:action', function(event, action){
        $scope.action = action
        $timeout(function(){
          $scope.$broadcast("event:table:action:"+action)
        }, 100)
        switch(action){
          case 'init':
            $rootScope.navigation_msg = "";
            break;
          case 'change_table':
            $rootScope.navigation_msg = "请选择您要换到的目标桌台";
            break;
          case 'merge_table':
            $rootScope.navigation_msg = "请选择要并台的目标桌台";
            break;
          case 'append_itemable':
            $rootScope.navigation_msg = "请选择要添加菜品";
            break;
          case 'subtract_itemable':
            $rootScope.navigation_msg = "请选择要删减菜品";
            break;
          case 'move_itemable':
            $rootScope.navigation_msg = "请选择要转台菜品";
            break;
          case 'change_vip_info':
            $rootScope.navigation_msg = "请选择会员信息";
            break;
          case 'bind_reservation_order':
            $rootScope.navigation_msg = "请选择要绑定的预订订座订单";
            break;
          case 'apply_coupon':
            $rootScope.navigation_msg = "请选择优惠券";
            break;
        }
      })

      $scope.$on('$destroy', function(){
        clear_choose_table_listener()
        clear_choose_itemable_listener()
        clear_choose_vip_info_listener()
        clear_choose_coupon_listener()
        clear_choose_order_listener()
        clear_table_subtract_itemable_listener()
        clear_table_move_itemable_listener()
        clear_subtract_itemable_listener()
        clear_move_itemable_listener()
        clear_table_action_listener()
        clear_settle_table_listener()
      })
    }])
