WebposModules.add_cell('order_choose')
angular.module('webpos.cells.order_choose', []).
  controller('orderChooseCell',
    ['$rootScope','$scope', '$timeout','OrderService', '$routeParams','BranchService','VipInfoService','PaginateService', 'ReservationDateService','TableService','RefreshService', 'NotifyService',
    function($rootScope, $scope, $timeout, OrderService, $routeParams, BranchService,VipInfoService, PaginateService, ReservationDateService, TableService, RefreshService, NotifyService){
      $scope.orders = []
      $scope.active_order = null
      $scope.page_orders = null
      $scope.order_type = '';

      $scope.is_filter = false;
      $scope.is_batch_op = false;
      $scope.key = null;
      $scope.active_order_type = '';
      $scope.pending_counts = {}

      $scope.bind_reservation_order = false

      // $scope.order_types = [
      //   { label: '所有订单', value: ''},
      //   { label: '堂点订单', value: 'Ddt::EatInHallOrder'},
      //   { label: '快餐订单', value: 'Ddt::FastfoodOrder'},
      //   { label: '预订订单', value: 'Ddt::ReservationOrder'},
      //   { label: '外卖订单', value: 'Ddt::DeliveryOrder'},
      //   { label: '买单订单', value: 'Ddt::PaymentOrder'},
      //   { label: '充值订单', value: 'Ddt::RechargeOrder'},
      // ]

      $scope.order_types=[{label: '所有订单', value: ''}]
         if($rootScope.has_feature('model_eat_in_hall')){
            $scope.order_types=$scope.order_types.concat([{ label: '堂点订单', value: 'Ddt::EatInHallOrder'}])
         }
         if($rootScope.has_feature('model_fastfood')){
            $scope.order_types=$scope.order_types.concat([{ label: '快餐订单', value: 'Ddt::FastfoodOrder'}])
         }      
         if($rootScope.has_feature('model_reservation')){
            $scope.order_types=$scope.order_types.concat([{ label: '预订订单', value: 'Ddt::ReservationOrder'}])
         }
         if($rootScope.has_feature('model_delivery')){
            $scope.order_types=$scope.order_types.concat([{ label: '外卖订单', value: 'Ddt::DeliveryOrder'}])
         }
         if($rootScope.has_feature('model_payment')){
            $scope.order_types=$scope.order_types.concat([{ label: '买单订单', value: 'Ddt::PaymentOrder'}])
         }       
         if($rootScope.has_feature('model_recharge')){
            $scope.order_types=$scope.order_types.concat([{ label: '充值订单', value: 'Ddt::RechargeOrder'}])
         }

      $scope.pay_methods = [
        { label: '支付宝',   value: 'alipay'},
        { label: '微信支付', value: 'wechatpay'},
        { label: '百度支付', value: 'baidupay'},
        { label: '货到付款', value: 'pay_on_receive'},
        { label: '当面付款', value: 'pay_on_face'}
      ]

      $scope.order_states = [
        { label: '待处理',   value: 'pending'},
        { label: '已确认',   value: 'confirmed'},
        { label: '已完成',   value: 'completed'}
      ]

      $scope.active_order_type = $scope.order_types[0]
      $scope.branch_id = $routeParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
        TableService.query($scope.branch.id, {}, function(tables){
          $scope.tables = tables;
        });
        var max_reservation_days = 7;
        if($scope.branch.reservation_setting){
          max_reservation_days = $scope.branch.reservation_setting.max_reservation_days;
        }
        var max_delivery_days = 7;
        if($scope.branch.delivery_setting){
          max_delivery_days = $scope.branch.delivery_setting.receive_delivery_order_within_days;
        }
        $scope.reservation_dates = ReservationDateService.get(max_reservation_days, 0);
        $scope.placed_at_dates = ReservationDateService.get(1, -20);
        $scope.delivery_dates = ReservationDateService.get(max_delivery_days, -max_delivery_days);
        $scope.delivery_times = $scope.branch.delivery_times;
      });

      $scope.vip_info_id = $routeParams.vip_info_id;
      $scope.base_user_id= $routeParams.base_user_id;
      if(typeof($scope.vip_info_id) != "undefined"){
        var params = {};
        params["q[id_eq]"] = $scope.vip_info_id;
        VipInfoService.query(params, function(vip_infos){
          $scope.vip_info = vip_infos[0]
        })
      }

      $scope.filter = function(){refresh_query();}

      $scope.search = function(){
        if($scope.search_key || $scope.search_delivery_date){
          refresh_query()
        }else{
          $scope.page_orders = null;
        }
      }

      $scope.search_by_key = function(key){
        $scope.search_key = null;
        $scope.set_flag("key")
        $scope.key = key;
      }

      var flag = "asc";
      $scope.reservation = function(){
        flag = flag == "asc" ? "desc" : "asc";
        var params = {};
        params.branch_id = $scope.branch_id;
        params["q[s]"] = "reservation_info_reservation_date " + flag
        params["q[type_eq]"] = "Ddt::ReservationOrder"

        $scope.page_orders = PaginateService.init(OrderService.query, params,
          function(orders){ $scope.orders = orders })
        $scope.page_orders.query()
      }


      $scope.change_active_order_type = function(order_type){
        $scope.set_flag("active_order_type")
        $scope.active_order_type = order_type
        refresh_query()
      }

      $scope.choose_order = function(order, event){
        var dom = $(event.target);
        // 如果点击的是勾选的那个 td, 直接返回
        if($(dom).attr("mk")=="true"){return;}
        $scope.active_order = order
        $scope.$emit("event:choose_order", order)
      }

      // RefreshService.add($scope, refresh_query, 30000)
      function refresh_query(){
        $scope.page_orders = PaginateService.init(OrderService.query, query_params(),
          function(orders){ $scope.orders = orders })
        $scope.page_orders.query()
      }

      RefreshService.add($scope, query_pending_counts, 5 * 60 * 1000)
      function query_pending_counts(){
        OrderService.pending_counts($scope.branch_id, function(pending_counts){
          $scope.pending_counts = pending_counts
        })
      }

      var lock_in_order_type = function(type){ return $scope.active_order_type && $scope.active_order_type.value == type}

      $scope.lock_in_eat_in_hall = function(){ return lock_in_order_type('Ddt::EatInHallOrder')}
      $scope.lock_in_fastfood = function(){return lock_in_order_type('Ddt::FastfoodOrder')}
      $scope.lock_in_reservation = function(){ return lock_in_order_type('Ddt::ReservationOrder')}
      $scope.lock_in_delivery = function(){ return lock_in_order_type('Ddt::DeliveryOrder')}
      $scope.lock_in_groupon = function() { return lock_in_order_type('Ddt::GrouponOrder')}
      $scope.lock_in_payment = function() { return lock_in_order_type('Ddt::PaymentOrder')}

      $scope.filter_by_reservation_time = function(){ return $scope.key == "reservation_info_reservation_date_cont"}
      $scope.filter_by_placed_at = function(){ return $scope.key == "placed_at_date_cont"}
      $scope.filter_by_table = function(){ return $scope.key == "table_name_cont"}

      function query_params(){
        params = {}
        params.branch_id = $scope.branch_id;
        if($scope.key){
          params = add_params(params)
        }else{
          if($scope.active_order_type){ params["q[type_eq]"] = $scope.active_order_type.value}
          if($scope.is_filter && $scope.order_type!="")   { params["q[type_eq]"] = $scope.order_type}
          if($scope.is_filter && $scope.pay_method!="")   { params["q[pay_method_eq]"] = $scope.pay_method}
          if($scope.is_filter && $scope.pay_item_state!=""){ params["q[pay_item_state_eq]"] = $scope.pay_item_state}
          if($scope.is_filter && $scope.order_state!="")  { params["q[state_eq]"] = $scope.order_state}
          if($scope.base_user_id){ params["q[base_user_id_eq]"] = $scope.base_user_id}
        }
        params["page"] = 1;
        return params;
      }

      function add_params(params){
        if($scope.key == "reservation_info_reservation_date_cont"){
          params["q[reservation_info_reservation_date_gteq]"] = $scope.search_key+" 00:00:00"
          params["q[reservation_info_reservation_date_lteq]"] = $scope.search_key+" 23:59:59"
          params["q[type_eq]"] = "Ddt::ReservationOrder";
        }
        else if($scope.key == "placed_at_date_cont"){
          params["q[placed_at_gteq]"] = $scope.search_key + " 00:00:00"
          params["q[placed_at_lteq]"] = $scope.search_key + " 23:59:59"
        }
        else if($scope.key == "shipment_delivery_time_cont"){
          params["q[shipment_delivery_date_eq]"] = $scope.search_delivery_date;
          if($scope.search_delivery_time_id){
            params["q[shipment_delivery_time_id_eq]"] = $scope.search_delivery_time_id;
          }
          params["q[type_eq]"] = "Ddt::DeliveryOrder";
        }
        else if($scope.key == "by_phone"){
          params["q[type_eq]"] = $scope.search_order_type;
          params["q[by_phone]"] = $scope.search_key;
        }
        else if ($scope.key == 'pay_item_state_paid'){
          params["q[pay_item_state_eq]"] = "paid"
        }
        else if ($scope.key == 'pay_item_state_unpaid'){
          params["q[pay_item_state_not_eq]"] = "paid"
        }
        else{
          params["q["+$scope.key+"]"] = $scope.search_key;
          if($scope.key == "table_name_cont"){
            params["q[type_eq]"] = "Ddt::EatInHallOrder";
          }else if($scope.key == "food_number_eq"){
            params["q[type_eq"] = "Ddt::FastfoodOrder";
          }
        }
        return params;
      }

      $scope.set_flag = function(flag){
        if(flag && flag == "is_filter")        { $scope.is_filter = true;} else { $scope.is_filter = false;}
        if(flag && flag == "is_batch_op")      { $scope.is_batch_op = true;}else{ $scope.is_batch_op = false;}
        if(flag && flag == "active_order_type"){}else{ $scope.active_order_type = null;}
        if(flag && flag == "key")              {}else{ $scope.key = null;}
      }

      var batch_op_success = function(){
        refresh_query();
        $rootScope.alert("状态修改成功");
      }

      $scope.batch_change_state = function(new_state){
        var checked_ids = order_ids();
        if(checked_ids.length == 0){
          $rootScope.alert("请先选择要操作的订单")
        }else{
          $rootScope.confirm("确认要修改选中订单的状态？", function(){
            OrderService.batch_change_state($scope.branch.id, checked_ids, new_state, batch_op_success);
          })
        }
      }

      function order_ids(){
        return $.map(checked_orders(), function(order){return order.id})
      }

      function checked_orders(){
        return $.map($scope.orders, function(order){if(order.marked){return order}});
      }

      // init
      $scope.search_by_key('number_eq');
      $rootScope.focus('.search-by-number input')
      // refresh_query();
      query_pending_counts();

      var clear_bind_reservation_order_listener = $scope.$on("event:table:action:bind_reservation_order", function(){
        $timeout(function(){
          $scope.bind_reservation_order = true
          $scope.change_active_order_type($scope.order_types[2])
        }, 200)
      })

      NotifyService.set_message_hander_in_scope($scope, "TABLE_ANTI_SETTLEMENT", function(msg){
        refresh_query()
      });

      NotifyService.set_message_hander_in_scope($scope, "NEW_ORDER_NOTIFICATION", function(msg){
        query_pending_counts()
      });

      var clear_table_focus_listener = $rootScope.$on("event:table:focus", function(event, table_name){
        //console.info("recv event:table:focus", table_name)
        $scope.search_by_key("table_name_cont")
        $scope.search_key = table_name
        refresh_query()
      });

      $scope.$on("$destroy", function(){
        clear_bind_reservation_order_listener()
        clear_table_focus_listener()
      })

    }]);
