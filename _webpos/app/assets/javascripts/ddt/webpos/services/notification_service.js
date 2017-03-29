WebposModules.add_service('notification');
angular.module('webpos.services.notification',[]).
  factory("NotificationService", ['$rootScope', '$timeout', 'NotifyService', 'TitleScrollService', 'TtsService',
    function($rootScope, $timeout, NotifyService, TitleScrollService, TtsService){
    var notifications = {}

    function start(){
      NotifyService.set_message_handler("NOTIFICATION", function(msg){
        if($rootScope.is_self_message(msg)){
          // 该操作来自本机
          return;
        }

        if(!notifications[msg.branch_id]){ notifications[msg.branch_id] = []; }
        notifications[msg.branch_id].unshift(msg)

        switch(msg.event_type){
          case "order_request_pay":{
            $rootScope.alert_messages.push({
              label: msg.content,
              click_fn: function(){
                $rootScope.alert('该桌台的顾客请求结帐，请前往处理!');
              }
            });
            break;
          }
          case "printer_notify_error":
          case "printer_notify_not_working":
          {
            $rootScope.alert_messages.push({
              label: msg.content,
              click_fn: function(){
                $rootScope.go_path('/webpos#/branches/'+ msg.branch_id + '/printers')
              }
            })
          }
        }

        if($rootScope.enable_play_sound){
          if(["table_opened", "order_hasten", "order_call_waiter", "order_request_pay"].indexOf(msg.event_type) != -1){
            TtsService.play(msg.content)
          }else{
            soundPlay()
          }
        }
        TitleScrollService.set('[' + msg.title + ']' + msg.content + '. ')
      });

      NotifyService.set_message_handler("PAY_SUCCESS", function(msg){
        // 显示条件
        // 1. 本门店
        if (msg.branch_id == $rootScope.branch_id
        // 2. 堂点
          && msg.order_type == 'eat_in_hall'
        // 3. 非快餐
          && msg.is_fast_food == false
        // 4. 非本终端
          && !$rootScope.settled_orders_cache.getItem(msg.order_id)
          //5.有桌台信息
          && msg.table_id
          //6、桌台就是当前活动的桌台
          && (msg.table_id == $rootScope.get_cache("active_table_id"))
        ){
          // 考虑到 confirm dialog 不可复用，为免并发出现导致 bug， 暂时用 alert 代替，以后有更好的方式后优化
          var alert_msg = "";
          if(msg.table_name){
            alert_msg += '桌台'+ msg.table_name + '的';
          }
          alert_msg += '订单' + msg.order_number + '已结算完成' // 用户微信结算、App结算或其它收银端结算
          alert(alert_msg)
        }
      });

      NotifyService.set_message_handler("SHIFT_STATE_CHANGED", function(msg){
        if (msg.branch_id == $rootScope.branch_id
        && $rootScope.terminal_id != msg.terminal_id){
          $rootScope.alert(msg.content, 15000)
          $timeout(function(){
            $rootScope.reload(true)
          }, 15000);
        }
      });
    }

    function get(branch_id){
      return notifications[branch_id]
    }

    function clear(branch_id){
      notifications[branch_id] = []
    }

    function length(branch_id){
      if(notifications[branch_id]){
        return notifications[branch_id].length
      }else{
        return 0
      }
    }

    function remove(branch_id, msg){
      var index = notifications[branch_id].indexOf(msg)
      notifications[branch_id].splice(index, 1)
    }

    return {
      start: start,
      get: get,
      clear: clear,
      length: length,
      remove: remove
    }
  }])