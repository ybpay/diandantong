Ddt.module("ddt.controllers.order", [])
.controller('deliveryOrderController', [
    '$rootScope', '$scope', '$location', '$interval', 'BaseOrderController','DeliveryOrderService', 'HastenController',
    function ($rootScope, $scope, $location, $interval, BaseOrderController, DeliveryOrderService, HastenController) {
      $rootScope.title = '外卖订单';
      $scope.order_type = 'delivery';

      BaseOrderController.action($scope, function () {
        HastenController.action($scope, DeliveryOrderService);
        $scope.$on('destroy', function(){
          $interval.cancel($scope.hasten_countdown_stop);
        })

        $scope.can_ship = ["pending", "shipping"].indexOf($scope.order.shipment_state) != -1

        $scope.can_hasten = function(){
          return $scope.permissions && $scope.permissions.indexOf('hasten') != -1 && $scope.order && $scope.can_service() && $scope.can_ship
        }

      })

      $scope.can_track_deliveryman = function(){return true}

      $scope.ship = function(){
        if($scope.can_ship){
          $rootScope.confirm("确认已收到货品？","该操作不可逆，如果您没有收到，请点击取消", function(){
            DeliveryOrderService.ship($scope.branch_id, $scope.order_id, function(order){
              $scope.order = order;
              $scope.can_ship = false;
            })
          })
        }
      }

      $scope.deliveryman_location = function(){
        DeliveryOrderService.refresh_location($scope.branch_id, $scope.order_id, function(location){
          $scope.order.deliveryman_location = location;
          if($scope.order.deliveryman_location.latitude){
            wx.openLocation({
              latitude: $scope.order.deliveryman_location.latitude,
              longitude: $scope.order.deliveryman_location.longitude,
              name: '配送员当前位置',
              address: '配送员当前位置',
              scale: 16
            })
          }else{
            $rootScope.$emit("events:receive_errors", "当前订单没有配送信息")
          }
        })
      }

    }])
.factory('orderInHallController', ['$rootScope', '$interval', 'BaseOrderController', 'HastenController',
  function($rootScope, $interval, BaseOrderController, HastenController){
    function action($scope, callback){
      BaseOrderController.action($scope, function () {
        HastenController.action($scope, $scope.service);

        if($scope.order.last_call_waiter_at_time){
          var now = new Date();
          var call_waiter_interval = parseInt(now.getTime() / 1000 - $scope.order.last_call_waiter_at_time)
          if(call_waiter_interval < 5 * 60){
            $scope.call_waiter_interval = call_waiter_interval
            $scope.call_waiter_countdown_stop = $interval(function(){
              $scope.call_waiter_interval ++
              if($scope.call_waiter_interval >= 5 * 60){
                $scope.call_waiter_interval = undefined
                $interval.cancel($scope.call_waiter_countdown_stop);
              }
            }, 1000)
          }
        }

        $scope.$on('$destroy', function() {
          $interval.cancel($scope.hasten_countdown_stop);
          $interval.cancel($scope.call_waiter_countdown_stop);
        });

        $scope.can_call_waiter = function(){
          return $scope.branch && !$scope.branch.disable_service && $scope.permissions && $scope.permissions.indexOf('call_waiter') != -1 && $scope.order && $scope.can_service()
        }

        $scope.can_call_waiter_now = function(){
          return $scope.can_call_waiter() && !$scope.call_waiter_interval
        }

        $scope.call_waiter_countdown = function(){
          if($scope.call_waiter_interval){
            var seconds = 5 * 60 - $scope.call_waiter_interval
            return "" + Math.floor(seconds / 60) + ":" + ('0' + seconds % 60).slice(-2)
          }
        }

        $scope.choose_waiter_service_item = false;
        $scope.show_options = function(flag){
          if($scope.can_call_waiter_now()){
            if(flag!=null){
              $scope.choose_waiter_service_item = flag;
            }else{
              $scope.choose_waiter_service_item = $scope.choose_waiter_service_item ? false : true;
            }
          }
        }

        $scope.call_waiter = function(service_name){
          if($scope.can_call_waiter_now()){
            $scope.service.call_waiter($scope.branch_id, $scope.order_id, service_name, function(){
              $scope.show_options(false);
              $scope.$emit("events:success_info", '呼叫服务员成功, 请耐心等待...');
              $rootScope.reload()
            })
          }
        }
        callback();
      })
    }
    return {action: action}

  }])
.controller('fastfoodOrderController', [
  '$rootScope', '$scope', 'orderInHallController','FastfoodOrderService',
  function($rootScope, $scope, orderInHallController, FastfoodOrderService){
    $rootScope.title = '快餐订单';
    $scope.order_type = 'fastfood';
    $scope.service = FastfoodOrderService;

    orderInHallController.action($scope, function(){
      $scope.can_call_waiter = function(){ return false;}
      $scope.can_append_itemable = function(){ return false;}

      $scope.paid = function(){
        $rootScope.reload();
      }
    });

  }])
.controller('eatInHallOrderController', [
    '$rootScope','$scope','orderInHallController','BaseOrderService', 'EatInHallOrderService',
    function ($rootScope, $scope, orderInHallController, BaseOrderService, EatInHallOrderService) {
      $rootScope.title = '堂点订单';
      $scope.order_type = 'eat_in_hall';
      $scope.service = EatInHallOrderService
      orderInHallController.action($scope, function(){

        $scope.can_request_pay = function(){
          return $scope.branch &&
                 !$scope.branch.disable_service &&
                 $scope.order &&
                 $scope.order.state != 'canceled' &&
                 ['none', 'unpaid'].indexOf($scope.order.pay_item_state) != -1 &&
                 $scope.order.ban_selfpay
        }

        $scope.choose_request_pay_method = false;
        $scope.show_pay_methods = function(flag){
          if(flag!=null){
            $scope.choose_request_pay_method = flag;
          }else{
            $scope.choose_request_pay_method = $scope.choose_request_pay_method ? false : true;
          }
        }

        $scope.can_append_itemable = function(){
          return $scope.order && ['none', 'unpaid'].indexOf($scope.order.pay_item_state) != -1;
        }

        // 请求服务员要支付
        $scope.pay_method_options = ['现金', '银行卡', '微信', '支付宝', '团购券', '会员卡'];
        $scope.request_pay = function(){
          if($scope.can_request_pay()){
            BaseOrderService.get($scope.order_type, $scope.branch_id, $scope.order_id, function(order){
              $scope.order = order;
              if(!order.ban_selfpay){
                $rootScope.confirm('请选择操作', '服务员已处理完该订单，订单信息已更新. 查看该信息？',
                  function(){
                    return;
                  },
                  '我要查看',
                  function(){
                    $scope.pay_online();
                  },
                  '直接买单'
                );
              }else{
                $scope.show_pay_methods(true);
              }
            })
          }
        }

        $scope.post_request_pay = function(pay_method_name){
          EatInHallOrderService.request_pay($scope.branch_id, $scope.order_id, pay_method_name, function(){
            $scope.show_pay_methods(false);
            $rootScope.alert('买单请求已通知到服务员，耐心等待服务员过来');
          })
        }

        $scope.can_pay_online = function(){
          return $scope.order.ban_selfpay==false && $scope.base_can_pay_online();
        }

        $scope.can_pay = function(){
          return $scope.order && !$scope.order.ban_selfpay &&  ['unpaid', 'none'].indexOf($scope.order.pay_item_state) != -1
        }

        $scope.pay = function(){
          $rootScope.go('/branches/'+$scope.branch_id+'/orders/eat_in_hall/'+$scope.order.id+'/pay')
        }

        $scope.base_can_pay_online = function(){
          return $scope.permissions && $scope.permissions.indexOf('pay_online') != -1 && $scope.order && $scope.order.state != 'canceled' && $scope.order.pay_item_state == 'unpaid' && ['alipay', 'wechatpay', 'baidupay'].indexOf($scope.order.pay_method) >= 0;
        }

        $scope.refresh = function(){
          BaseOrderService.get($scope.order_type, $scope.branch_id, $scope.order_id, function (order) {
            $scope.order = order;
          });
        }

      });


    }]).controller('reservationOrderController', [
    '$rootScope', '$scope', 'BaseOrderController', 'DdtConst',
    function ($rootScope, $scope, BaseOrderController, DdtConst) {
      $rootScope.title = '预订订单';
      $scope.order_type = 'reservation';
      BaseOrderController.action($scope, function () {
        // 注册分享信息
        $rootScope.shareRecordTrigger = {
          triggerBeforeCreateRecord: function(resp, cfg){
            var shareLink = '/branches/{branch_id}/orders/invitation/{order_id}'.supplant({
              branch_id: $scope.branch_id,
              order_id: $scope.order_id
            });
            var share_url = UrlParser.change_parameter(cfg.link, '_ng_path', shareLink);
            angular.extend(cfg, {
              title: '邀请函',
              desc: '我在' + $scope.branch.name + '预订了桌台，邀您一块举杯共聚吧',
              imgUrl: $rootScope.img_url('/assets/ddt/yao.png'),
              link: UrlParser.change_parameter(DdtConst.oauth_user_info_url, 'redirect_uri', encodeURIComponent(share_url))
            });
          }
        }
        // 分享按钮
        $scope.go_invitation_order = function(){
          $rootScope.go('/branches/{branch_id}/orders/invitation/{order_id}'.supplant({
            branch_id: $scope.branch_id,
            order_id: $scope.order_id
          }));
        };

        $scope.can_go_invitation_order = function(){
          return $scope.order.state != 'canceled' && DdtConst.wechat_account_be_verified;
        };
      })
    }]).controller('grouponOrderController', [
    '$rootScope', '$scope', 'BaseOrderController',
    function ($rootScope, $scope, BaseOrderController) {
      $rootScope.title = '团购订单';
      $scope.order_type = 'groupon';
      BaseOrderController.action($scope, function () {
        $scope.coupon_detail = function(code){
          $rootScope.go('/user/{coupon_type_str}s/{coupon_id}'.supplant({
            coupon_type_str: code.coupon_type_str,
            coupon_id: code.coupon_id
          }))
        }
      })

    }]).controller('rechargeOrderController', [
    '$rootScope', '$scope', 'BaseOrderController',
    function ($rootScope, $scope, BaseOrderController) {
      $rootScope.title = '充值订单';
      $scope.order_type = 'recharge';
      BaseOrderController.action($scope, function () {
      })

    }]).controller('paymentOrderController', [
    '$rootScope', '$scope', 'BaseOrderController',
    function ($rootScope, $scope, BaseOrderController) {
      $rootScope.title = '买单订单';
      $scope.order_type = 'payment';
      BaseOrderController.action($scope, function () {
      })

    }]).factory('HastenController', ['$rootScope','$interval',
      function($rootScope, $interval){
        function action($scope, OrderService){
          // 催单（仅在外送和堂点使用到）
          if($scope.order.last_hasten_at_time){
            var now = new Date();
            var hasten_interval = parseInt(now.getTime() / 1000 - $scope.order.last_hasten_at_time)
            if(hasten_interval < 5 * 60){
              $scope.hasten_interval = hasten_interval
              $scope.hasten_countdown_stop = $interval(function(){
                $scope.hasten_interval ++
                if($scope.hasten_interval >= 5 * 60){
                  $scope.hasten_interval = undefined
                  $interval.cancel($scope.hasten_countdown_stop);
                }
              }, 1000)
            }
          }

          $scope.can_service = function(){
            return ["pending", "confirmed", "merged"].indexOf($scope.order.state) >= 0
          }

          $scope.choose_hasten_line_item = false;
          $scope.show_hasten_modal = function(flag){
            if($scope.can_hasten_now()){
              $scope.choose_hasten_line_item = flag;
            }
          }

          $scope.can_hasten = function(){
            return $scope.branch && !$scope.branch.disable_service && $scope.permissions && $scope.permissions.indexOf('hasten') != -1 && $scope.order && $scope.can_service()
          }

          $scope.can_hasten_now = function(){
            return $scope.can_hasten() && !$scope.hasten_interval
          }

          $scope.hasten_countdown = function(){
            if($scope.hasten_interval){
              var seconds = 5 * 60 - $scope.hasten_interval
              return "" + Math.floor(seconds / 60) + ":" + ('0' + seconds % 60).slice(-2)
            }
          }

          $scope.hasten = function(line_item_id){
            if($scope.can_hasten_now()){
              OrderService.hasten($scope.branch_id, $scope.order_id, line_item_id, function(){
                $scope.$emit("events:success_info", '催单成功, 请耐心等待...');
                $rootScope.reload()
              })
            }else{
              $rootScope.alert('当前不能催单')
            }
          }
        }
        return {
            action: action
          }
      }]).factory('BaseOrderController', [
    '$rootScope', '$routeParams', '$window', '$location', '$timeout', 'BaseOrderService', 'BranchService', 'UserService', 'ShopService', 'DdtConst', 'HistoryUrlService',
    function ($rootScope, $routeParams, $window, $location, $timeout, BaseOrderService, BranchService, UserService, ShopService, DdtConst, HistoryUrlService) {

      function action($scope, callback) {
        $scope.branch_id = $routeParams.branch_id;
        $scope.order_id = $routeParams.order_id;
        $scope.order = null;
        $scope.permissions = []

        ShopService.get(function(shop){
          $scope.enable_foreign = shop.enable_foreign;
          $scope.shop = shop;
        });

        UserService.get(function(user){
          $scope.user = user;
        })

        BranchService.get({id: $scope.branch_id}, function (branch) {
          $scope.branch = branch;
          BaseOrderService.get($scope.order_type, $scope.branch_id, $scope.order_id, function (order) {
            $scope.order = order;
            if(UrlParser.query_parameter('pay_online') === "true" || $location.search().pay_online ){
              $scope.pay_online()
            }
            if (callback) {
              callback()
            }
          })
        });

        BaseOrderService.get_permissions($scope.order_type, $scope.branch_id, $scope.order_id, function(resp){
          $scope.permissions = resp.permissions
        })

        $scope.is_my_order = function(){
          return $scope.user && $scope.order && $scope.user.id == $scope.order.base_user_id
        }

        $scope.can_cancel = function () {
          // 已经支付的订单用户不可以取消。
          return $scope.permissions && $scope.permissions.indexOf('cancel') != -1 && $scope.order && $scope.order.state == 'pending' && $scope.order.pay_item_state != 'paid';
        };

        $scope.can_request_pay = function(){
          return false
        }

        $scope.can_pay_online = function () {
          return $scope.permissions && $scope.permissions.indexOf('pay_online') != -1 && $scope.order && $scope.order.state != 'canceled' && $scope.order.pay_item_state == 'unpaid' && ['alipay', 'wechatpay', 'baidupay'].indexOf($scope.order.pay_method) >= 0;
        };

        $scope.can_pay = function(){
          return false;
        }

        $scope.can_exchange_code = function(){
          return $scope.permissions && $scope.permissions.indexOf('exchange_code') != -1 && $scope.order && $scope.order.exchange_code_id && ['pending', 'confirmed'].indexOf($scope.order.state) >= 0 && ['reservation'].indexOf($scope.order_type) >= 0
        }

        $scope.can_append_itemable = function(){
          return $scope.permissions && $scope.permissions.indexOf('append_itemable') != -1 && $scope.order
        }

        $scope.can_go_comment = function(){
          return $scope.order && !$scope.order.is_commented;
        }

        $scope.go_append_itemable = function(){
          $rootScope.go_page('cart', '/branches/' + $scope.branch_id + '/orders/' + $scope.order_id + '/' + $scope.order_type + '/append_itemable')
        }

        $scope.cancel = function () {
          if ($scope.can_cancel()) {
            $rootScope.confirm('温馨提示', '您确定要取消该订单？', function(){
              BaseOrderService.cancel($scope.order_type, $scope.branch_id, $scope.order_id, function (resp) {
                $rootScope.reload()
              })
            });
          }
        };

        $scope.can_ask_for_invoice = function(){
          return $scope.branch && $scope.branch.support_invoice && $scope.order && $scope.order.state!="canceled" && $scope.order.invoice == null;
        }

        $scope.ask_for_invoice = function() {
          $rootScope.go("/branches/" + $scope.branch_id + "/orders/" + $scope.order_type + "/" + $scope.order_id +"/invoice")
        }

        $scope.exchange_codes = function(line_item_id){
          var codes = [];
          if($scope.order && $scope.order.exchange_codes){
            angular.forEach($scope.order.exchange_codes, function(item){
              if(item.line_item_id == line_item_id){
                codes =  item.codes;
              }
            });
          }
          return codes;
        }

        $scope.go_exchange_code = function(){
          $rootScope.go_page('my', "/exchange_codes/" + $scope.order.exchange_code_id)
        }

        $scope.go_comment = function(){
          $rootScope.go('/branches/' + $scope.branch_id + '/orders/' + $scope.order_id + '/comment/new');
        }

        $scope.go_back = function(){
          var url = HistoryUrlService.get_back_url()
          if('/' == url.path){
            $rootScope.go_page('main', '/branches/'+$scope.branch_id)
          }else{
            $rootScope.go_page('my', '/user/profile')
          }
        }

        $scope.pay_online = function(){
          if($scope.can_pay_online()){
            $rootScope.go('/branches/' + $scope.branch_id + '/orders/' + $scope.order_type + '/' + $scope.order_id +'/pay_online')
          }
        }
      }

      return {
        action: action
      };
    }]);
