WebposModules.add_directive('wp_footbar')
angular.module('webpos.directives.wp_footbar', [])
  .directive('wpFootbar', ['$rootScope', '$window', '$location', '$http', '$routeParams', 'BranchService', 'AccountService',
    function ($rootScope, $window, $location, $http, $routeParams, BranchService, AccountService) {
    return {
      restrict: 'EA',
      scope: {
        branch_id: '@branchId'
      },
      replace: true,
      templateUrl: '/webpos/partials/_directives/wp-footbar.html',
      link: function(scope, element, attrs){
        scope.branch_id = $routeParams.branch_id || $location.search().branch_id
        BranchService.get(scope.branch_id, function(branch){
          scope.branch = branch
        })
        AccountService.get(function(account){
          scope.has_multi_branches = account && account.branches && account.branches.length > 1
        })

        scope.menus = []
          if($rootScope.has_feature('model_eat_in_hall') && $rootScope.can("branch", "eat_in_hall_order", "create")){
            scope.menus = scope.menus.concat([{ key: 'eat_in_hall', name: '堂点'    , path: '/branches/'+scope.branch_id+'/eat_in_hall'  , controller_name: 'branchEatInHallController', need_shift: true, icon: 'cutlery' }])
          }
          if($rootScope.has_feature('model_fastfood') && $rootScope.can("branch", "fastfood_order", "create")){
            scope.menus = scope.menus.concat([{ key: 'fast_food'  , name: '快餐'    , path: '/branches/'+scope.branch_id+'/fast_food'    , controller_name: 'branchFastFoodController', need_shift: true, icon: 'delicious' }])
          }
          if($rootScope.has_feature('model_delivery') && $rootScope.can("branch", "delivery_order", "create")){
            scope.menus = scope.menus.concat([{ key: 'delivery'   , name: '外卖'    , path: '/branches/'+scope.branch_id+'/delivery'     , controller_name: 'branchDeliveryController', need_shift: true, icon: 'truck' }])
          }
          if($rootScope.has_feature('model_reservation') && $rootScope.can("branch", "reservation_order", "create")){
            scope.menus = scope.menus.concat([{ key: 'reservation', name: '预订'    , path: '/branches/'+scope.branch_id+'/reservation'  , controller_name: 'branchReservationController', need_shift: true, icon: 'calendar' }])
          }
          if($rootScope.has_feature('model_payment') && $rootScope.can("branch", "payment_order", "create")){
            scope.menus.push({ key: 'payment', name: '买单'    , path: '/branches/'+scope.branch_id+'/payment'      , controller_name: 'branchPaymentController', need_shift: true, icon: 'rmb' })
          }

          if($rootScope.has_feature('model_queue') && $rootScope.can("branch", "guest_queue", "create")){
            scope.menus = scope.menus.concat([{ key: 'guest_queue', name: '排号'    , path: '/branches/'+scope.branch_id+'/guest_queues' , controller_name: 'guestQueuesController', need_shift: false, icon: 'pause' }])
          }

          if($rootScope.has_feature('model_order') && $rootScope.can("branch", "order", "show")){
            scope.menus = scope.menus.concat([{ key: 'orders'     , name: '订单' , path: '/branches/'+scope.branch_id+'/orders'       , controller_name: 'ordersController', need_shift: true, icon: 'list' }])
          }
          if($rootScope.has_feature('model_estimate_clear') && $rootScope.can("branch", "product", "estimate_clear")){
            scope.menus = scope.menus.concat([{ key:'estimate_clear',name: '估清' , path: '/branches/'+scope.branch_id+'/estimate_clear'    , controller_name: 'estimateClearController', need_shift: false, icon: 'minus-square-o'  }])
          }

          if ($rootScope.has_feature('model_vip_info') && $rootScope.can("shop", "user", "show")) {
            scope.menus.push({key: 'vip_infos',name: '会员',path: '/branches/' + scope.branch_id + '/vip_infos',controller_name: 'VipInfosController',need_shift: false,icon: 'user'})
          }
          if($rootScope.has_feature('model_coupon_exchange') &&(($rootScope.can("shop", "coupon", "exchange") || $rootScope.can("shop", "groupon", "exchange") || $rootScope.can("shop", "voucher", "exchange")))){
            scope.menus.push({ key:'coupon_exchange', name: '券核销' , path: 'branches/'+scope.branch_id+'/promotions'    , controller_name: 'promotionController', need_shift: true, icon: 'cc'  })
          }
          if($rootScope.has_feature('model_bill_center') && $rootScope.can("branch", "bill_center", "discount_list")){
            scope.menus.push({ key:'bill_center',name: '单据' , path: '/branches/'+scope.branch_id+'/bill_center'    , controller_name: 'billCenterController', need_shift: false, icon: 'list-alt'  })
          }
          if ($rootScope.has_feature('model_kitchen') && $rootScope.can("branch", "litp", "show")){
            scope.menus.push({ key: 'kitchen', name: '厨控', location: '/webpos/kitchen#shop/branch/' + scope.branch_id, need_shift: false, icon: 'bookmark-o fa-rotate-180'})
          }
          if ($rootScope.has_feature('model_printer') && $rootScope.can("branch", "printer", "show")){
            scope.menus.push({ key: 'printers', name: '打印机', path: 'branches/' + scope.branch_id + '/printers', need_shift: false, icon: 'print'})
          }


        var folded_menu_keys = get_ddb_cache("folded_menu_keys")
          var default_folded_menu_keys = "coupon_exchange estimate_clear bill_center switch_offline kitchen guest_queue payment reservation"
          angular.forEach(scope.menus, function(menu){
            if(folded_menu_keys){
              menu.folded = !!(folded_menu_keys.indexOf(menu.key) > -1)
            }else{
              menu.folded = !!(default_folded_menu_keys.indexOf(menu.key) > -1)
            }
          })

          scope.active_menu = scope.menus[0]

          scope.change_active_menu = function(menu){
            scope.active_menu = menu;
            if (menu.onclick){
              if (!menu.onclick.apply(menu)){
                return;
              }
            }
            if(menu.name === '外卖' && scope.branch.delivery_setting && !scope.branch.delivery_setting.today_can_order){
              $rootScope.alert("外送截止时间已过,不能下外送订单")
            }else if (menu.path){
                  $location.path(menu.path);
            } else if (menu.location){
              $window.location.href = menu.location
            }
          }

          scope.go_branch = $rootScope.go_branch
          scope.go = $rootScope.go
          scope.is_controller = $rootScope.is_controller

          scope.show_folded_menus = false
          scope.toggle_folded_menus = function(){
            scope.show_folded_menus = !scope.show_folded_menus
          }

          scope.get_nest_menu_class = function(){
            var count = scope.menus.filter(function(menu){
                return menu.folded && (!menu.need_shift || (scope.branch && scope.branch.on_shift))
              }).length + 1
            return "wp-nest-menus-count-" + count
          }

          scope.get_folded_menu_keys = function(){
            var keys = []
            angular.forEach(scope.menus, function(menu){
              if(menu.folded){
                keys.push(menu.key)
              }
            })
            return keys.join(" ")
          }

          scope.menu_setting_modal = {
            show: false,
            open: function(){ this.show = true; },
            close: function(){ this.show = false; }
          }

          scope.toggle_menu_fold = function(menu){
            menu.folded = !menu.folded
            set_ddb_cache("folded_menu_keys", scope.get_folded_menu_keys())
          }
          if(get_ddb_cache("show_menus") == null){
            scope.show_menus = true
          }else{
            scope.show_menus = (get_ddb_cache("show_menus") == 'true')
          }
          scope.toggle_show_menus = function(){
            scope.show_menus = !scope.show_menus
            set_ddb_cache("show_menus", scope.show_menus ? 'true' : 'false')
          }
      }
    }
  }]);