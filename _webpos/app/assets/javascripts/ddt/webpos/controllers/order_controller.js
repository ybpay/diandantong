WebposModules.add_controller('order')
angular.module('webpos.controllers.order', []).
  controller('ordersController',
    ['$rootScope','$scope','$timeout', 'OrderService','$routeParams', 'BranchService','BaseOrderService','SetReprintAction', 'ReservationOrderService','TableZoneService','TableService','ShipmentService','DeliveryOrderService','SetCancelOrderAction', 'EatInHallOrderService','LineItemService','AppendItemableAction', 'AccountService', 'TtsService', 'FastfoodOrderService', 'PrintService', 'PayItemService',
    function($rootScope, $scope, $timeout, OrderService, $routeParams, BranchService, BaseOrderService, SetReprintAction, ReservationOrderService, TableZoneService, TableService, ShipmentService, DeliveryOrderService, SetCancelOrderAction, EatInHallOrderService, LineItemService,AppendItemableAction, AccountService, TtsService, FastfoodOrderService, PrintService, PayItemService){
      $scope.order_id = null
      $scope.order_type = null
      $scope.order = null

      $scope.action = "init" // [init append_itemable subtract_itemable]
      $scope.toggle_action = function(new_action){
        if($scope.action === new_action){
          $scope.action = 'init'
        }else{
          $scope.action = new_action
        }
        if($scope.action === "subtract_itemable"){
          $timeout(function(){
            $scope.$broadcast("event:subtract_itemable:order", $scope.order)
          }, 500)
        }
      }

      $scope.branch_id = $routeParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch

        AppendItemableAction.init($scope.branch_id, function(){return $scope.order}, function(append_itemables){
          $scope.append_itemables = append_itemables
        })
        $scope.change_active_append_itemable     = AppendItemableAction.change_active_append_itemable;
        $scope.add_append_itemable               = AppendItemableAction.add_append_itemable;
        $scope.remove_append_itemable            = AppendItemableAction.remove_append_itemable;
        $scope.can_append_itemables              = AppendItemableAction.can_append_itemables;
        $scope.confirm_append_itemables          = AppendItemableAction.confirm_append_itemables;
        $scope.change_append_itemable_note       = AppendItemableAction.change_append_itemable_note;
        $scope.batch_change_append_itemable_note = AppendItemableAction.batch_change_append_itemable_note;
        $scope.change_append_itemable_gift       = AppendItemableAction.change_append_itemable_gift;
        $scope.clear_append_itemables            = AppendItemableAction.clear_append_itemables;
        $scope.change_weight                     = AppendItemableAction.change_weight;
        $scope.edit_line_item                    = AppendItemableAction.edit_line_item;
        $scope.append = {}
        $scope.$watch("append.note", function(){ AppendItemableAction.change_note($scope.append.note) })
        $scope.$on("event:order:append_itemable:success", function(event, order){
          $scope.order = order
          $rootScope.alert("加菜成功")
          $scope.toggle_action('init')
        })

        $scope.can_append_itemable = function(){ return $rootScope.can("branch", "order", "append") && $scope.order && ($scope.order.type === "Ddt::EatInHallOrder" || ($scope.order.type === "Ddt::DeliveryOrder" && $scope.order.track_from == "FromWebpos")) && ($scope.order.state === 'pending' || $scope.order.state === 'confirmed') && $scope.order.pay_item_state !== 'paid' }

        SetCancelOrderAction.init(function(){ return $scope.order })
        $scope.can_cancel_order = SetCancelOrderAction.can_cancel_order;
        $scope.cancel_order     = SetCancelOrderAction.cancel_order;
        $scope.$on("event:order:cancel", function(event, order){
          $rootScope.reload();
        })

        SetReprintAction.init(function(){ return $scope.order })
        $scope.choose_reprint_targets = SetReprintAction.choose_reprint_targets;

        $scope.$on("$destroy", function(){
          AppendItemableAction.dispose()
          SetCancelOrderAction.dispose()
          SetReprintAction.dispose()
        })
      })

      var clear_choose_order_listener = $scope.$on("event:choose_order", function(event, order){
        if(!$scope.order_id || $scope.order_id != order.id){
          $scope.order = order;
          $scope.order_type = order.type_str
          $scope.order_id = order.id
          $scope.action = "init"
        }
      })

      var clear_watch_order_id = $scope.$watch("order_id", function(){
        reload_order()
      })
      $scope.$on("$destroy", function(){
        clear_watch_order_id()
      })

      function reload_order(){
        if($scope.order_id){
          BaseOrderService.get($scope.order_type, $scope.branch_id, $scope.order_id, function(order){
            $scope.order = order
          })
        }
      }

      $scope.confirm = function(){
        BaseOrderService.confirm($scope.order_type, $scope.branch_id, $scope.order_id, function(order){
          $scope.order = order
        })
      }

      $scope.complete = function(){
        BaseOrderService.complete($scope.order_type, $scope.branch_id, $scope.order_id, function(order){
          $scope.order = order
        })
      }

      $scope.call_customer = function(){
        var call_text = "亲爱的" + $scope.order.food_number +"号顾客，您的餐品已准备完毕，请您到配餐台自助取餐。";
        TtsService.play(call_text, 2);
        FastfoodOrderService.call_customer($scope.branch_id, $scope.order.id, function(){})
      }

      $scope.print_product_bill = function(){
        PrintService.print_product_bill($scope.order)
      }
      $scope.print_consume_bill = function(){
        PrintService.print_consume_bill($scope.order)
      }

      $scope.can_confirm = function(){ return $rootScope.can("branch", 'order', "confirm") && $scope.order && $scope.order.state === 'pending' && $scope.order_type != "recharge"}
      $scope.can_complete = function(){ return $rootScope.can("branch", 'order', "complete") && $scope.order && $scope.order.state === 'confirmed'}
      $scope.can_call_customer = function(){ return $scope.order && $scope.order.type == 'Ddt::FastfoodOrder'}
      $scope.can_init_refund = function(){ return $scope.order && $scope.order.type == "Ddt::RechargeOrder" && $scope.order.state == "completed"}

      $scope.is_role = function(role, uniq){
        return AccountService.is_role(role, uniq);
      }

      $scope.can_go_settle = function(){
        return $rootScope.can("branch", "order", "settle") && $rootScope.branch && $rootScope.branch.on_shift;
      };

      $scope.can_settle = function(){
        if($scope.order && $scope.order.type === "Ddt::ReservationOrder" && $scope.order.prepayment_type === "prepay_for_order"){return false}
        return $scope.order && ($scope.order.state === 'pending' || $scope.order.state === 'confirmed') && $scope.order.pay_item_state != 'paid'
      }
      $scope.go_settle = function(){
        if (!$scope.can_go_settle()){
          $rootScope.alert("您没有结算的权限，只有收银员可以进行结算。");
          return;
        }

        if (!$scope.can_settle()){
          $rootScope.alert("该订单不能结算");
          return;
        }
        $rootScope.go("/branches/" + $scope.branch_id + "/orders/" + $scope.order.id + "/settle/"+$scope.order.type_str)
      }

      // 修改预订信息
      $scope.reservation_order_modal = {
        can_open: function(){
          return $scope.order && $scope.order.type === "Ddt::ReservationOrder" && $scope.order.state === 'pending'
        },
        show: false,
        order:{},
        gender_collection: [{ value: 'male', label: '先生'}, { value: 'female', label: '女士'}],
        open: function(){
          $scope.reservation_order_modal.show = true
          $scope.reservation_order_modal.order = {
            name: $scope.order.name,
            phone: $scope.order.phone,
            gender: $scope.order.gender,
            note: $scope.order.note
          }
        },
        close: function(){
          $scope.reservation_order_modal.show = false
        },
        can_submit: function(){
          var order = $scope.reservation_order_modal.order
          return order && order.name && order.phone && order.gender
        },
        submit: function(){
          if($scope.reservation_order_modal.can_submit()){
            ReservationOrderService.edit_reservation_info($scope.branch_id, $scope.order.id, $scope.reservation_order_modal.order, function(order){
              $scope.order = order
              $scope.reservation_order_modal.close()
              $rootScope.alert("更新成功")
            })
          }
        }
      }

      // 预订订单转堂点
      $scope.reservation_change_modal = {
        can_open: function(){
          return $scope.order && $scope.order.type === "Ddt::ReservationOrder"
        },
        can_change: function(){
          return $scope.order && $scope.order.type === "Ddt::ReservationOrder" && $scope.order.prepayment_type === 'prepay_for_order' &&  ($scope.order.state === 'pending' || $scope.order.state === 'confirmed') && !$scope.order.related_order_id
        },
        show: false,
        order:{},
        table_zones: null,
        active_table_zone: null,
        open: function(){
          if($scope.reservation_change_modal.can_change()){
            $scope.reservation_change_modal.show = true
            TableZoneService.query($scope.branch_id, function(table_zones){
              $scope.reservation_change_modal.table_zones = table_zones
              angular.forEach($scope.reservation_change_modal.table_zones, function(table_zone){
                if(table_zone.id == $scope.order.table_zone_id){
                  $scope.reservation_change_modal.active_table_zone = table_zone
                }
              })
              $scope.reservation_change_modal.order = {
                table_zone_id: $scope.order.table_zone_id,
                table_id: null,
                note: ''
              }
            })
          }else{
            var errors = []
            if($scope.order.prepayment_type !== 'prepay_for_order'){
              errors.push("未点菜的预订订单不能转为堂点")
            }
            if($scope.order.state === 'canceled'){
              errors.push("该预订订单已经取消, 不能转为堂点")
            }
            if($scope.order.state === 'completed'){
              errors.push("该预订订单已经完成, 不能转为堂点")
            }
            if($scope.order.related_order_id){
              errors.push("该预订订单已经转为堂点, 不能再次转换")
            }
            if(errors.length > 0){
              $rootScope.alert(errors.join("<br/>"))
            }
          }
        },
        change_table_zone: function(){
          $scope.reservation_change_modal.order.table_zone_id = $scope.reservation_change_modal.active_table_zone.id
        },
        close: function(){
          $scope.reservation_change_modal.show = false
        },
        can_submit: function(){
          var order = $scope.reservation_change_modal.order
          return order && order.table_zone_id && order.table_id
        },
        submit: function(){
          if($scope.reservation_change_modal.can_submit()){
            $rootScope.confirm("转为堂点之前，请确认顾客已经到店。确认转为堂点?", function(){
              ReservationOrderService.change_to_eat_in_hall($scope.branch_id, $scope.order.id, $scope.reservation_change_modal.order, function(order){
                $scope.order = order
                $scope.reservation_change_modal.close()
                $rootScope.alert("转堂点成功")
              })
            })
          }
        }
      }

      // 预订绑定桌台
      $scope.reservation_bind_table_modal = {
        can_open: function(){
          return $scope.order && $scope.order.type === "Ddt::ReservationOrder"  && !$scope.order.table_id
        },
        show: false,
        table: null,
        tables: [],
        open: function(){
          $scope.reservation_bind_table_modal.show = true
          TableService.get_reservation_tables($scope.branch_id, $scope.order.reservation_info.reservation_date, $scope.order.reservation_info.reservation_time_point_id, function(tables){
            $scope.reservation_bind_table_modal.tables = tables
          })
        },
        close: function(){
          $scope.reservation_bind_table_modal.show = false
        },
        can_submit: function(){
          return $scope.reservation_bind_table_modal.table
        },
        submit: function(){
          if($scope.reservation_bind_table_modal.can_submit()){
            ReservationOrderService.bind_table($scope.branch_id, $scope.order.id, $scope.reservation_bind_table_modal.table.id, function(order){
              $scope.order = order
              $scope.reservation_bind_table_modal.close()
              $rootScope.alert("预订绑定桌台成功")
            })
          }
        }
      }


      // 指定配送员
      $scope.delivery_man_modal = {
        can_open: function(){
          return $scope.order && $scope.order.type === "Ddt::DeliveryOrder" && $scope.order.state === 'confirmed'
        },
        show: false,
        active_delivery_man: {},
        delivery_mans: [],
        open: function(){
          $scope.delivery_man_modal.show = true
          $scope.delivery_man_modal.active_delivery_man = {},
          ShipmentService.query("delivery_mans", $scope.branch_id, function(delivery_mans){
            $scope.delivery_man_modal.delivery_mans = delivery_mans
            $scope.delivery_man_modal.delivery_mans.push({ id: null, name: "取消指派"})
          })
        },
        close: function(){
          $scope.delivery_man_modal.show = false
        },
        can_submit: function(){
          return true
        },
        submit: function(){
          if($scope.delivery_man_modal.can_submit()){
            DeliveryOrderService.assign_delivery_man($scope.branch_id, $scope.order.id, $scope.delivery_man_modal.active_delivery_man.id, function(order){
              $scope.order = order
              $scope.delivery_man_modal.close()
              if($scope.delivery_man_modal.active_delivery_man.id){
                $rootScope.alert("指派成功")
              }else{
                $rootScope.alert("取消指派成功")
              }
            })
          }
        }
      }


      // 加菜
      var clear_choose_itemable_listener = $scope.$on("event:choose_itemable", function(event, itemable){
        $scope.add_append_itemable(itemable, true)
      })

      // 减菜
      var clear_subtract_itemable_listener = $scope.$on("event:subtract_itemable:success", function(event) {
        $scope.toggle_action('init')
        reload_order()
      })

      $scope.$on("$destroy", function(){
        clear_choose_order_listener()
        clear_choose_itemable_listener()
        clear_subtract_itemable_listener()
      })

      // 单品改价
      $scope.current_line_item = null;
      $scope.change_line_item = function(line_item){
        if(line_item && $scope.current_line_item == line_item){
          $scope.current_line_item = null
        }else{
          $scope.current_line_item = line_item
        }
      }

      $scope.change_price_modal = {
        show: false,
        new_price: "",
        open: function(){
          if($scope.current_line_item){
            this.new_price = ""
            this.show = true
          }else{
            $rootScope.alert("请先点击选择单品")
          }
        },
        close: function(){ this.show = false},
        submit: function(){
          if(this.can_submit()){
            LineItemService.change_price($scope.branch_id, $scope.order.id, $scope.current_line_item.id, this.new_price, function(){
              $rootScope.alert("改价成功")
              $scope.change_price_modal.show = false
              $scope.change_price_modal.new_price = ""
              $scope.current_line_item = null
              reload_order()
            })
          }
        },
        can_submit: function(){
          return this.new_price
        }
      }

      $scope.can_change_price = function(){
        return $rootScope.can("branch", "order", "change_item_price");
      }

      // 反结帐
      $scope.anti_settlement = function(){
        $rootScope.auth_action("branch", "order", "anti_settlement", {branch_id: $scope.branch_id}, function(needAuth){
          var Service = {
            "Ddt::EatInHallOrder": EatInHallOrderService,
            "Ddt::FastfoodOrder" : FastfoodOrderService
          }[$scope.order.type]

          function execute_anti_settlement(){
            Service.anti_settlement($scope.branch_id, $scope.order_id, function (result) {
              $rootScope.clear_authorizer()
              if(result.msg){
                $scope.order = JSON.parse(result.order);
                $rootScope.alert(result.msg);
              }else{
                $scope.order = result;
              }
            })
          }

          if (needAuth) {
            execute_anti_settlement();
          }else{
            $rootScope.confirm("确认反结帐?", function(){
              execute_anti_settlement();
            })
          }
        });
      }

      $scope.can_anti_settlement = function(){
        return $scope.order && ["Ddt::EatInHallOrder", "Ddt::FastfoodOrder"].indexOf($scope.order.type) != -1 && $scope.order.state === 'confirmed' && $scope.order.pay_item_state == 'paid'
      }

      $scope.subtract_itemables = function(){
        if('subtract_itemable' != $scope.action ){
          $rootScope.auth_action("branch", "order", "subtract", {branch_id: $scope.branch_id}, function(){
            $scope.toggle_action('subtract_itemable')
          })
        }
      }

      $scope.trace_waiter_modal = {
        show: false,
        waiter_id: null,
        waiters: [],
        open: function(){
          BranchService.get_waiter_names({id: $scope.branch_id}).$promise.then(function(resp){
            $scope.trace_waiter_modal.waiters = resp
          })
          this.waiter_id = $scope.order.waiter_id
          this.show = true
        },
        close: function(){
          this.waiter_id = null
          this.show = false
        },
        click: function(waiter_id){
          this.waiter_id = waiter_id
        },
        can_submit: function(){
          return this.waiter_id != null
        },
        submit : function(){
          if(this.waiter_id == null) {
            $rootScope.alert("请选择一位服务员")
          }
          else {
            EatInHallOrderService.trace_waiter($scope.branch_id,$scope.order.id,this.waiter_id,function(result){
              if(result){
                $scope.order = result
                $rootScope.alert("记录成功")
              }else{
                $rootScope.alert("记录失败")
              }
            })
            this.show = false
          }
        }
      }

      $scope.can_refund = function(pay_item){
        var match_pay_method = ["alipay", "alipay_offline"].indexOf(pay_item.name_sym) >= 0
        return $rootScope.can("branch", "order", "refund") && pay_item.state == 'paid' && pay_item.pay_platform && match_pay_method
      }

      $scope.can_simple_refund = function(){
        if ($scope.order && !$scope.order.multi_pay_item){
          if ($scope.order.state === 'confirmed' && $scope.order.pay_item_state == 'paid'){
            return true;
          }
        }
        return false;
      }

      $scope.refund = function(pay_item){
        if ($scope.can_refund(pay_item)){
          $rootScope.auth_action('branch', 'order', 'refund', {branch_id: $scope.branch_id}, function () {
            $rootScope.confirm("确定要退款吗?", function () {
              PayItemService.refund($scope.branch_id, $scope.order.id, pay_item.id, function (new_pay_item) {
                pay_item.state = new_pay_item.state
                pay_item.state_name = new_pay_item.state_name
                reload_order()
              });
            });
          });
        }
      }

      $scope.init_refund = function(){
        if($scope.can_init_refund()){
          $rootScope.confirm("确认充值退款?", function(){
            var RechargeOrder = BaseOrderService.get_resource("recharge")
            RechargeOrder.init_refund({ branch_id: $scope.branch_id, id: $scope.order.id }, {}, function(resp){
              $scope.order = resp
              $rootScope.alert("充值退款已提交, 等待审核")
            })
          })
        }
      }
    }]);
