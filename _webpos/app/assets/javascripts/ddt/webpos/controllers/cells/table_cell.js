 WebposModules.add_cell('table')
angular.module('webpos.cells.table', []).
  controller('tableCell',
    ['$rootScope','$scope','$timeout', 'TableService','$routeParams','BranchService','SetCancelOrderAction', 'EatInHallOrderService', 'SetReprintAction','BaseOrderService','LineItemService','AppendItemableAction', 'AccountService', 'PrintService', 'SetDiscountPlanAction', 'RefreshService', 'HotkeyService',
    function($rootScope,$scope,$timeout, TableService, $routeParams, BranchService,SetCancelOrderAction, EatInHallOrderService, SetReprintAction, BaseOrderService, LineItemService, AppendItemableAction, AccountService, PrintService, SetDiscountPlanAction, RefreshService, HotkeyService){
      $scope.table_id = null
      $scope.table = null
      $scope.action = 'init' // ['init', 'change_table', 'merge_table', 'append_itemable', 'subtract_itemable', "move_itemable"]

      $scope.$on("event:choose_table:init:reset", function(event, table){
        $scope.table = null;
        $scope.table_id = null;
        $scope.order = null;
      })

      $scope.$on("event:back", function(){
        $scope.toggle_action("init")
      })

      var clear_choose_table_init_listener = $scope.$on("event:choose_table:init", function(event, table){
        if(table == null || typeof table == 'undefined'){
          $scope.table = null;
          $scope.table_id = null;
          $scope.order = null;
        }else{
          if($scope.table_id != table.id || $scope.table && $scope.table.updated_at != table.updated_at){
            table_changed(table)
          }
          try_open_guestnum_modal();
        }
      })

      // 开台时间
      RefreshService.add($scope, refresh_opened_time, 60000)
      function refresh_opened_time(){
        if($scope.table && $scope.table.last_opened_at){
          $scope.table_opened_time_str = $rootScope.time_since_from($scope.table.last_opened_at)
        }
      }


      function table_changed(table){
        $scope.table_id = table.id
        $scope.table = table;
        $scope.order = null;
        if($scope.is_ordered() || $scope.is_paid() || $scope.is_check_outing()){
          if(!$scope.table.current_order_id){
            $rootScope.alert("检测到桌子状态异常，可能是收银台操作失当所致，请立即刷新页面进行尝试。如果问题仍然不能解决，请尝试 强制清台 予以解决！");
            return false;
          }
          var cached_table_order = $rootScope.get_cache("order_of_table_" + table.id)
          if(cached_table_order && cached_table_order.table_id == $scope.table_id && cached_table_order.id == table.current_order_id){
            // set cache
            $scope.order = cached_table_order;
            $scope.table.order = cached_table_order;
            $scope.order_id = cached_table_order.id;
            refresh_opened_time()
            // load without mask
            TableService.resource.get({ branch_id: $rootScope.branch_id, id: $scope.table_id, skip_mask: true}).$promise.then(function(table){
              if($scope.table_id == table.id){
                $scope.table = table
                set_table(table)
                $rootScope.set_cache("order_of_table_" + table.id, table.order)
                refresh_opened_time()
              }
            })

          }else{
            load_table();
          }
        }
      }

      function try_open_guestnum_modal(){
        if($scope.is_idle() && $rootScope.can('branch', 'table', 'open')){
          $scope.open_table();
        }
      }

      var clear_change_table_listener = $scope.$on("event:choose_table:change_table", function(event, table){
        if(table.id != $scope.table_id && table.workflow_state === 'idle'){
          $rootScope.confirm("确定要将 "+$scope.table.name_with_zone+" 换到 "+table.name_with_zone+" ？", function(){
            change_table(table)
          })
        }else{
          $rootScope.alert("不允许的操作， 请选择一张空闲的桌子。");
        }
      })

      var clear_merge_table_listener = $scope.$on("event:choose_table:merge_table", function(event, table){
        if(table.id != $scope.table_id && table.workflow_state === 'ordered'){
          $rootScope.confirm("确定要将 "+$scope.table.name_with_zone+" 并到 "+table.name_with_zone+" ？", function(){
            merge_table(table)
          })
        }else{
          var hint = table.id == $scope.table_id ? "不能合并自身" : "请选择一张已下单的桌子。"
          $rootScope.alert("不允许的操作， " + hint)
        }
      })


      var clear_append_itemable_listener = $scope.$on("event:choose_itemable:append_itemable", function(event, itemable){
        $scope.add_append_itemable(itemable, true)
      });

      var clear_bind_reservation_order_listener = $scope.$on("event:choose_order:bind_reservation_order", function(event, order){
        $rootScope.confirm("确定将该预订订单在绑定到订单上吗？", function(){
          bind_reservation_order(order)
        })
      })

      var clear_subtract_itemable_success_listener = $scope.$on("event:table:subtract_itemable:success", function(event){
        $scope.toggle_action('init')
        load_table()
      })

      var clear_move_itemable_success_listener = $scope.$on("event:table:move_itemable:success", function(event){
        $scope.toggle_action('init')
        load_table()
      })

      $scope.branch_id = $routeParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
        AppendItemableAction.init($scope.branch_id, function(){return $scope.table.order}, function(append_itemables){
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
          $scope.table.order = order
          $scope.toggle_action('init')
        })

        SetReprintAction.init(function(){ return $scope.table.order })
        $scope.choose_reprint_targets = SetReprintAction.choose_reprint_targets;
        SetCancelOrderAction.init(function(){ return $scope.table.order })
        $scope.can_cancel_order = SetCancelOrderAction.can_cancel_order;
        $scope.cancel_order     = SetCancelOrderAction.cancel_order;
        $scope.$on("event:order:cancel", function(event, order){
          $rootScope.reload();
        })

        $scope.$on("$destroy", function(){
          AppendItemableAction.dispose()
          SetReprintAction.dispose()
          SetCancelOrderAction.dispose()
        })
      })

      $scope.print_product_bill = function(){
        PrintService.print_product_bill($scope.order)
      }
      $scope.print_last_append_product_bill = function(){
        PrintService.print_last_append_product_bill($scope.order)
      }
      $scope.print_consume_bill = function(){
        PrintService.print_consume_bill_from_table($rootScope.branch_id, $scope.table.id)
        TableService.check_out($rootScope.branch_id, $scope.table.id, {is_local_printed: $rootScope.local_printer_configed()}, function(resp){
          $scope.table.workflow_state = 'check_outing'
          $rootScope.$broadcast('event:table:state_change')
        })
      }
      $scope.cancel_check_out = function(){
        TableService.cancel_check_out($rootScope.branch_id, $scope.table.id, function(resp){
          $scope.table.workflow_state = 'ordered'
          $rootScope.$broadcast('event:table:state_change')
        })
      }
      $scope.can_allow_selfpay = function(){
        return $scope.table && $scope.table.order && $scope.table.order.track_from == 'FromWechat' && $scope.table.order.ban_selfpay
      }
      $scope.allow_selfpay = function(){
        $rootScope.confirm('该桌子所在区域为不可自助结账区域，请确认你已经处理完该桌子的订单，再点击确认', function(){
          EatInHallOrderService.allow_selfpay($scope.branch_id, $scope.table.order.id, function(order){
            $scope.table.order = order;
          })
        })
      }
      $scope.can_print_product_bill = function(){
        return $scope.table && $scope.table.order
      }
      $scope.can_print_last_append_product_bill = function(){
        if($scope.table && $scope.table.order){
          for(index in $scope.table.order.line_items){
            if ($scope.table.order.line_items[index].is_append){
              return true
            }
          }
        }
        return false
      }
      $scope.can_print_consume_bill = function(){
        return $scope.table && $scope.table.order && $scope.is_ordered() && !$scope.is_check_outing();
      }
      $scope.order = function(){ return $scope.table.order}
      $scope.get_order_id = function(){ return $scope.order.id}
      $scope.order_type = "eat_in_hall"

      function load_table(){
        if($scope.table_id){
          TableService.get($rootScope.branch_id, $scope.table_id, function(table){
            $scope.table = table
            set_table(table)
            $rootScope.set_cache("order_of_table_" + table.id, table.order)
            refresh_opened_time()
          })
        }else{
          $scope.table = null;
        }
      }

      function set_table(table){
        if(table.order){
          $scope.order = table.order;
          $scope.order_id = table.order.id;
        }
      }

      $scope.go_cart = function(){
        $rootScope.go("/branches/" + $rootScope.branch_id + "/tables/" + $scope.table_id + "/cart")
      }



      $scope.toggle_action = function(new_action){
        if(!$scope.table.current_order_id){
          $rootScope.alert("检测到桌子状态异常，可能是收银台操作失当所致，请立即刷新页面进行尝试。如果问题仍然不能解决，请尝试 强制清台 予以解决！");
          return false;
        }
        $scope.advance_modal.close();
        if($scope.action === new_action){
          $scope.action = 'init'
        }else{
          $scope.action = new_action
        }
        $scope.$emit("event:table:action", $scope.action)

        if($scope.action === 'subtract_itemable'){
          $timeout(function(){
            $scope.$emit("event:table:subtract_itemable:order", $scope.table.order)
          }, 500)
        }
        if($scope.action === 'move_itemable'){
          $timeout(function(){
            $scope.$emit("event:table:move_itemable:order", $scope.table.order)
          }, 500)
        }
        if($scope.action == "append_itemable"){
          $scope.clear_append_itemables(true)
        }
      }

      function change_table(table){
        EatInHallOrderService.change_table($scope.branch_id, $scope.table.order.id, table.id, function(){
          $rootScope.alert("换台成功")
          $rootScope.go_branch($scope.branch)
          $rootScope.$broadcast('event:table:state_change')
        })
      }

      function merge_table(table){
        EatInHallOrderService.merge_table($scope.branch_id, $scope.table.order.id, table.id, function(){
          $rootScope.alert("并台成功")
          $rootScope.go_branch($scope.branch)
          $rootScope.$broadcast('event:table:state_change')
        })
      }

      function bind_reservation_order(order){
        EatInHallOrderService.bind_reservation_order($scope.branch_id, $scope.table.order.id, order.id, function(order){
          $rootScope.alert("绑定预订订单成功")
          $scope.toggle_action('init')
          $rootScope.$broadcast('event:table:state_change')
        })
      }

      $scope.is_idle    = function(){ return $scope.table && $scope.table.workflow_state === 'idle'; }
      $scope.is_opened  = function(){ return $scope.table && $scope.table.workflow_state === 'opened'; }
      $scope.is_ordered = function(){ return $scope.table && ($scope.table.workflow_state === 'ordered' ); }
      $scope.is_paid    = function(){ return $scope.table && $scope.table.workflow_state === 'paid'; }
      $scope.is_check_outing = function(){return $scope.table && $scope.table.workflow_state === 'check_outing'}
      $scope.is_order_pending  = function(){ return $scope.table && $scope.table.order && $scope.table.order.state === 'pending'; }

      $scope.can_bind_reservation_order = function(){ return $rootScope.can("branch", "eat_in_hall_order", "bind_reservation_order") && $scope.table && $scope.table.order && !$scope.table.order.related_order_id; }
      $scope.can_go_history_order = function(){return $rootScope.can('branch', 'order', 'show')}


      $scope.open_table = function(){
        $scope.guest_num_modal.open();
      }

      $scope.can_clear_table = function(){
        return $scope.is_opened() || $scope.is_paid()
      }

      $scope.clear_table = function(table) {
        if($scope.is_idle()) { return; }
        if(!$scope.can_clear_table()) {
          var info = table.name_with_zone + ' 尚未买单，请结算后再清台';
          $rootScope.alert(info)
        } else {
          var confirmation = '确定要将 ' + table.name_with_zone + ' 清台？';
          $rootScope.confirm(confirmation, function() {
            TableService.clear($scope.branch_id, table.id, function() {
              $scope.$broadcast("event:choose_table:init");
              $rootScope.alert("清台成功");
              $rootScope.$broadcast('event:table:state_change')
            });
          });
        }
      };

      $scope.subtract_itemable = function(){
        if('subtract_itemable' != $scope.action ){
          $rootScope.auth_action('branch', 'order', 'subtract', { branch_id: $scope.branch_id }, function(){
            $scope.toggle_action('subtract_itemable')
          })
        }
      }

      $scope.move_itemable = function(){
        if('move_itemable' != $scope.action ){
          $scope.toggle_action('move_itemable')
        }
      }

      $scope.confirm_order = function(){
        if($scope.is_order_pending()){
          $rootScope.confirm("确认订单?", function(){
            BaseOrderService.confirm('eat_in_hall', $scope.branch_id, $scope.table.order.id, function(order){
              load_table()
            })
          })
        }
      }


      $scope.can_update_guest_num = function(){
        return $scope.is_opened() || $scope.is_ordered() || $scope.is_check_outing();
      }

      $scope.update_guest_num = function(){
        $scope.guest_num_modal.open()
      }

      $scope.guest_num_modal = {
        show: false,
        guest_num: 2,
        page: 1,
        is_update: false,
        guest_nums: function(){
          var i = (this.page - 1) * 5 + 1;
          return [i, i+1, i+2, i+3, i+4]
        },
        next_page: function(){ this.page ++; },
        pre_page: function(){ if(this.page > 1) this.page --; },
        open: function(){
          if($scope.is_idle()){
            this.is_update = false;
          }else{
            this.guest_num = $scope.table.guest_num
            this.is_update = true;
          }
          this.show = true;
        },
        submit: function(go_cart){
          TableService.open($scope.branch_id, $scope.table_id, parseInt(this.guest_num), function(table){
            $scope.table = table
            $scope.guest_num_modal.reset();
            $scope.guest_num_modal.cancel();
            if(go_cart){
              $scope.go_cart()
            }else{
              $rootScope.$broadcast("event:table:state_change", table)
            }
          })
        },
        update_guest_num: function(){
          if($scope.table.order){
            EatInHallOrderService.update_guest_num($scope.branch_id, $scope.table.order.id, parseInt(this.guest_num), function(order){
              $scope.table.order = order
              $scope.table.guest_num = order.guest_num
              $scope.guest_num_modal.reset();
              $scope.guest_num_modal.cancel();
            })
          }else{
            TableService.update_guest_num($scope.branch_id, $scope.table_id, parseInt(this.guest_num), function(table){
              $scope.table = table;
              $scope.guest_num_modal.reset();
              $scope.guest_num_modal.cancel();
            })
          }
        },
        can_submit: function(){
          return true;
        },
        cancel: function(){
          this.show = false;
        },
        reset: function(){
          this.guest_num = 2;
          this.is_update = false;
        }
      }

      $scope.is_role = function(role, uniq){
        return AccountService.is_role(role, uniq)
      }

      $scope.can_go_settle = function(){
        return $rootScope.can("branch", "order", "settle") && $rootScope.branch && $rootScope.branch.on_shift && $scope.table && ['check_outing', 'ordered'].indexOf($scope.table.workflow_state)!=-1;
      };

      $scope.go_settle = function(){
        if ($scope.can_go_settle()) {
          $rootScope.go("/branches/" + $scope.branch_id + "/orders/" + $scope.table.order.id + "/settle/"+ $scope.table.order.type_str)
        }else{
          if(!$rootScope.can("branch", "order", "settle")){
            $rootScope.alert("您没有结算权限，只有收银员可以进行结算。");
          }
        }
      }
      // 催单，催菜
      $scope.can_hasten = function(){
        return !$scope.is_paid();
      }
      $scope.can_change_line_item_weight = function(){
        return $rootScope.can("branch", "eat_in_hall_order", "change_line_item_weight") && !$scope.is_paid() && $scope.current_line_item && $scope.current_line_item.itemable_type == 'Ddt::VariantPackage';
      }
      $scope.change_line_item_weight = function(){
        var weight = parseFloat($scope.current_line_item.name.match(/(重量: ([\d\.]+))/)[2])
        $scope.current_line_item.weight = weight;
        $rootScope.change_weight_modal.open($scope.current_line_item, function(variant_package, weight){
          EatInHallOrderService.change_weight($scope.branch_id, $scope.table.order.id,
            {
              line_item_id: $scope.current_line_item.id,
              weight: weight
            }, function(order){
            $scope.order = order;
            $scope.table.order = order;
          })
        });
      }

      $scope.hasten_order = function(){

        $rootScope.confirm("确定催单?", function(){
          EatInHallOrderService.hasten($scope.branch_id, $scope.table.order.id, {}, function(){
            $rootScope.alert("催单成功");
          })
        })
      }

      $scope.hasten_line_item = function(){
        $rootScope.confirm("确定催菜/叫起?", function(){
          EatInHallOrderService.hasten($scope.branch_id, $scope.table.order.id, {
            line_item_id: $scope.current_line_item.id
          }, function(){
            $rootScope.alert("催菜/叫起 成功");
          })
        })
      }

      // 单品改价
      $scope.current_line_item = null;
      $scope.change_line_item = function(line_item){
        if(line_item && $scope.current_line_item == line_item){
          $scope.current_line_item = null
        }else{
          $scope.current_line_item = line_item
        }
      }

      $scope.can_change_price = function(){
        return $rootScope.can("branch", "order", "change_item_price") && !$scope.is_paid();
      };

      $scope.change_price = function(){
        $rootScope.auth_action("branch", "order", "change_item_price", {branch_id: $scope.branch_id }, function(){
          $scope.change_price_modal.open()
        });
      }

      $scope.change_price_modal = {
        show: false,
        new_price: "",
        open: function(){
          if($scope.action == 'init'){
            if($scope.current_line_item){
              this.new_price = ""
              this.show = true
            }else{
              $rootScope.alert("请先点击选择单品")
            }
          }
        },
        close: function(){ this.show = false},
        submit: function(){
          if(this.can_submit()){
            LineItemService.change_price($scope.branch_id, $scope.order.id, $scope.current_line_item.id, this.new_price, function(){
              $rootScope.$broadcast('event:table:state_change')
              $rootScope.clear_authorizer()
              $rootScope.alert("改价成功")
              $scope.change_price_modal.show = false
              $scope.change_price_modal.new_price = ""
              $scope.current_line_item = null
              load_table()
            })
          }
        },
        can_submit: function(){
          return this.new_price
        }
      }

      // 高级
      $scope.advance_modal = {
        show: false,
        open: function(){
          this.show = true
        },
        close: function(){
          this.show = false
        }
      }

      $scope.trace_waiter_modal = {
        show: false,
        waiter_id: null,
        waiters: [],
        open: function(){
          if ($rootScope.waiters == undefined){
            BranchService.get_waiter_names({id: $scope.branch_id}).$promise.then(function(resp){
              $scope.trace_waiter_modal.waiters = resp
            })
          }
          this.waiter_id = $scope.table.order.waiter_id
          $scope.advance_modal.close();
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
            EatInHallOrderService.trace_waiter($scope.branch_id, $scope.table.order.id, this.waiter_id, function(result){
              if(result){
                $rootScope.alert("记录成功")
                $scope.table.order = result;
              }else{
                $rootScope.alert("记录失败")
              }
            })
            this.show = false
          }
        }
      }

      $scope.go_history_order = function(){
        var table_name = $scope.table.name
        $timeout(function(){
          //console.info("$emit event:table:focus of table: " + $scope.table.name)
          $rootScope.$emit("event:table:focus", table_name)
        }, 1000)
        $rootScope.go("/branches/" + $rootScope.branch_id + "/orders")
      }

      $scope.force_clear = function(){
        $rootScope.confirm("确定强制清台？", function(){
          TableService.force_clear($scope.branch_id, $scope.table_id, function(){
          })
        })
      }

      $scope.can_force_clear = function(){
        return !$scope.is_idle()
      }

      $scope.force_clear = function() {
        if($scope.can_force_clear()) {
          var confirmation = '确定要将 ' + $scope.table.name_with_zone + ' 强制清台？';
          $rootScope.confirm(confirmation, function() {
            TableService.force_clear($scope.branch_id, $scope.table.id, function() {
              $scope.$broadcast("event:choose_table:init");
              $rootScope.alert("清台成功");
              $rootScope.go_branch($scope.branch);
              $rootScope.$broadcast('event:table:state_change')
            });
          });
        }
      };

      /* 折扣方案 */
      $scope.discount_plan = SetDiscountPlanAction.init(function(){
        return $scope.order;
      });
      $scope.discount_plan.order_changed = function(new_order){
        $scope.order = new_order;
        if($scope.table && $scope.table.order){
          $scope.table.order = new_order
          $rootScope.$broadcast('event:table:state_change')
        }
      }

      $scope.key_of_append        = HotkeyService.get_key('append_itemable')
      $scope.key_of_subtract      = HotkeyService.get_key('subtract_itemable')
      $scope.key_of_print_consume = HotkeyService.get_key('print_consume_bill')
      $scope.key_of_print_product = HotkeyService.get_key('print_product_bill')


      var unbind_hotkey_append_itemable = $rootScope.bind_key($scope.key_of_append, function(){
        if($scope.is_ordered() && $rootScope.can('branch','order','append')){
          $scope.toggle_action('append_itemable')
        }
      })
      var unbind_hotkey_subtract_itemable = $rootScope.bind_key($scope.key_of_subtract, function(){
        if($scope.is_ordered()){
          $scope.subtract_itemable();
        }
      })
      var last_print_consume_bill_at = 0;
      var last_print_product_bill_at = 0;
      var unbind_hotkey_print_consume_bill = $rootScope.bind_key($scope.key_of_print_consume, function(){
        var now = Date.now()
        if($scope.can_print_consume_bill() && now - last_print_consume_bill_at > 3000){
          last_print_consume_bill_at = Date.now()
          $scope.print_consume_bill();
        }
      })
      var unbind_hotkey_print_product_bill = $rootScope.bind_key($scope.key_of_print_product, function(){
        var now = Date.now()
        console.log(now - last_print_product_bill_at)
        if($scope.can_print_product_bill() && now - last_print_product_bill_at > 3000){
          last_print_product_bill_at = Date.now()
          $scope.print_product_bill();
        }
      })
      var clear_settle_listener  = $scope.$on("event:choose_table:settle", $scope.go_settle)

      $scope.$on("$destroy", function(){
        $scope.discount_plan.destroy();
        clear_choose_table_init_listener()
        clear_change_table_listener()
        clear_merge_table_listener()
        clear_append_itemable_listener()
        clear_bind_reservation_order_listener()
        clear_subtract_itemable_success_listener()
        clear_move_itemable_success_listener()
        clear_settle_listener()
        unbind_hotkey_append_itemable()
        unbind_hotkey_subtract_itemable()
        unbind_hotkey_print_consume_bill()
        unbind_hotkey_print_product_bill()
      })
    }])
