"use strict";

Ddt.module('ddt_app.controllers.branch', [])
  .factory('BranchesHelper', ['$rootScope', '$route', 'BranchService', 'QueryService', 'LoadMoreServiceFactory',
    function ($rootScope, $route, BranchService, QueryService, LoadMoreServiceFactory) {
      return {
        executeCommonAction: function ($scope, restriction) {
          $scope.branch_request_params = QueryService.getCombineQuery();
          angular.extend($scope.branch_request_params, restriction);

          var loadMoreService = LoadMoreServiceFactory.createLoadMoreService({
            id: $route.current.controller,
            onLoadMore: function(page, per_page, timestamp, success){
              angular.extend($scope.branch_request_params, {
                page: page,
                per_page: per_page,
                'query[updated_at_lteq]': new Date(timestamp)
              });
              BranchService.query($scope.branch_request_params, function(data){
                if(success) { success(data) }
              });
            },

            update: function(olds){
              $scope.branches = olds;
            }
          });

          // 获取过滤器
          BranchService.filters({}, function (data) {
            $scope.navFilters = data;
          });

          // 选择过滤器时的动作
          $scope.onPickupFilter = function (filter, pickupFilters) {
            $scope.branch_request_params = {};
            $.each(pickupFilters, function(i, f) {
              $scope.branch_request_params[f.op] = f.value;
            });
            angular.extend($scope.branch_request_params, restriction);
            loadMoreService.reload();
            loadMoreService.loadMore(true);
          };

          $(document).on('scroll', function(){
            if (!loadMoreService.isLoading()) {
              var scrollTop = $(document.documentElement).scrollTop() || $(document.body).scrollTop();
              if (scrollTop + $(window).height() > $(document).height() - 30) {
                loadMoreService.loadMore();
              }
            }
          });

          // 位置更新了，需要重载门店信息
          $rootScope.$on("events:update_location", function(location_data){
            loadMoreService.reload();
            loadMoreService.loadMore(true);
          });

        }
      };
    }])

      .controller('branchesController',
        ['$rootScope', '$scope', 'BranchesHelper',
            function ($rootScope, $scope, BranchesHelper){

                //
                // 还没有处理的字段
                // tag: '促',
                // average_consume: '59',
                //    tuans: [{
                //        type: 'voucher_version',
                //        name: '100元代金券仅售88元'
                //    }]
                $rootScope.title = "门店列表";
              BranchesHelper.executeCommonAction($scope, {});
            }])
      .controller('deliveryBranchesController',
        ['$rootScope', '$scope', 'BranchesHelper',
            function ($rootScope, $scope, BranchesHelper) {
                $rootScope.title = "门店列表";
                BranchesHelper.executeCommonAction($scope, {'query[use_delivery_setting_eq]': true});
            }])

        .controller('branchController', [
            '$rootScope', '$scope', '$routeParams', '$location', 'BranchService', 'GeolocationService', 'FavoriteBranchService', 'ShopService', 'DdtConst',
            function ($rootScope, $scope, $routeParams, $location, BranchService, GeolocationService, FavoriteBranchService, ShopService, DdtConst) {
                var branch_id = $routeParams.branch_id;

                ShopService.get(function(shop){
                  $scope.enable_foreign = shop.enable_foreign;
                  $scope.shop = shop
                });

                var rebindWechatShareInfo = function(branch) {
                  $rootScope.shareRecordTrigger = {
                    triggerBeforeCreateRecord: function(resp, cfg) {
                      angular.extend(cfg, {
                        title: branch.name,
                        desc: branch.notice,
                        imgUrl: DDBUtil.makeAssetUrl(branch.image, DdtConst, true) ||
                        DDBUtil.makeAssetUrl($scope.shop.image, DdtConst, true)
                      });
                    }
                  };
                };

                BranchService.get({id: branch_id}, function (data) {
                    $scope.branch = data;
                    ShopService.get_branch_type($scope.branch.branch_type_id, function(branch_type){
                        $scope.branch_type = branch_type;
                        bindOperationNavs($scope.branch, branch_type);
                    });
                    $rootScope.title = $scope.branch.name;

                    rebindWechatShareInfo($scope.branch);
                });

                GeolocationService.get_location_address(function(location_address){
                    $scope.location_address = location_address;
                })

                $scope.open_location = function(){
                  $rootScope.view_branch_on_wechat_map($scope.branch)
                }


                $scope.toggleFavorite = function(){
                    if($scope.branch.is_followed){
                        FavoriteBranchService.destroy(branch_id, function(){
                            $scope.branch.is_followed = !$scope.branch.is_followed;
                        });
                    }else{
                        FavoriteBranchService.save(branch_id, function(){
                            $scope.branch.is_followed = !$scope.branch.is_followed;
                        });
                    }
                }

                var go_to = function(key){
                  if($scope.branch && $scope.branch['use_'+key+'_setting']){
                    var match = ({
                      reservation : {path: '/branches/' + $scope.branch.id + '/reservation_time_points', page: 'cart'},
                      queue       : {path: '/branches/' + $scope.branch.id + '/guest_queue', page: 'queue'},
                      pay_online  : {path: '/branches/' + $scope.branch.id + '/pay_online', page: 'cart'}
                    })[key]
                    if(match){
                      $rootScope.go_page(match.page, match.path)
                    }else{
                      $rootScope.go_page('cart', '/branches/' + $scope.branch.id + '/products/' + key)
                    }
                  }
                }

                function bindOperationNavs(branch, branch_type){
                  var btns = Base.newBtns($location);
                  if($rootScope.has_feature('reservation_on_wechat') && branch.use_reservation_setting && branch_type.show_reservation_img){
                    btns.push({
                      label: branch_type.reservation_img_text||'预订',
                      img: branch_type.reservation_img||'/images/ddt/my/reservation.png',
                      func: function(){
                        go_to('reservation');
                      }
                    });
                  }

                  if($rootScope.has_feature('eat_in_hall_on_wechat') && branch.use_eat_in_hall_setting && branch_type.show_order_in_seat_img){
                    btns.push({
                      label: branch_type.order_in_seat_img_text||'点菜',
                      img: branch_type.order_in_seat_img||'/images/ddt/my/eat_in_hall.png',
                      func: function(){
                        $rootScope.toggle_show_eat_in_hall_select();
                      }
                    });
                  }

                  if($rootScope.has_feature('delivery_on_wechat') && branch.use_delivery_setting && branch_type.show_delivery_img){
                    btns.push({
                      label: branch_type.delivery_img_text||'外卖',
                      img: branch_type.delivery_img||'/images/ddt/my/delivery.png',
                      func: function(){
                        go_to('delivery');
                      }
                    });
                  }

                  if($rootScope.has_feature('fastfood_on_wechat') && branch.use_fastfood_setting && branch_type.show_fastfood_img){
                    btns.push({
                      label: branch_type.fastfood_img_text||'快餐',
                      img: branch_type.fastfood_img||'/images/ddt/my/fastfood.png',
                      func: function(){
                        go_to('fastfood');
                      }
                    });
                  }

                  if($rootScope.has_feature('base_queue') && branch.use_queue_setting && branch_type.show_queue_img){
                    btns.push({
                      label: branch_type.queue_img_text||'排队',
                      img: branch_type.queue_img||'/images/ddt/queue/queue.png',
                      func: function(){
                        go_to('queue');
                      }
                    });
                  }

                  if($rootScope.has_feature('payment_on_wechat') && branch.use_pay_online_setting && branch_type.show_pay_online_img){
                    btns.push({
                      label: branch_type.pay_online_img_text||'买单',
                      img: branch_type.pay_online_img||'/images/ddt/my/pay.png',
                      func: function(){
                        go_to('pay_online');
                      }
                    });
                  }


                  $scope.operation_nav_groups = btns.group(2);
                }

            }]);
