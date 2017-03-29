WebposModules.add_controller('queue')
angular.module('webpos.controllers.queue', []).
  controller('QueueController', ['$rootScope', '$scope', 'BranchService', 'Box', '$state', "$stateParams", "QueueSetting", "GuestQueue", "PaginateService", "RefreshService", "TtsService", "PrintService", "QueueFormService", "NotifyService", "LocalStorageCache",
    function($rootScope, $scope, BranchService, Box, $state, $stateParams, QueueSetting, GuestQueue, PaginateService, RefreshService, TtsService, PrintService, QueueFormService, NotifyService, LocalStorageCache){
      var branch_id = $stateParams.branch_id
      $scope.branch_id = branch_id

      // cell
      $scope.queue_settings = []
      $scope.active_queue_setting = null
      $scope.active_history = false
      $scope.active_queue_setting = null
      $scope.guest_queues = []
      $scope.page_guest_queues = null
      $scope.queue_states = []

      $scope.new_guest_queue = {}

      BranchService.get(branch_id, function(branch){
        $scope.branch = branch
        refresh_waited_time()
        RefreshService.add($scope, refresh_waited_time,    60000)
        QueueSetting.query({ branch_id: $scope.branch_id }).$promise.then(function(queue_settings){
          $scope.queue_settings = queue_settings;
          set_active_queue_setting($scope.queue_settings);
          QueueFormService.set_queue_names($scope.queue_settings)
          if($scope.queue_settings.length > 0 && $scope.branch.arranging_setting_mode == "free_choice"){
            $scope.new_guest_queue.queue_setting_id = $scope.queue_settings[0].id;;
          }
          refresh_queue_states()
          NotifyService.set_message_hander_in_scope($scope, 'QUEUE_STATE_CHANGE', queue_state_change_handler)
        })
      })

      function refresh_waited_time(){
        if(!$scope.active_history){
          var now = new Date()
          angular.forEach($scope.guest_queues, function(guest_queue){
            var created_at = Date.parse(guest_queue.created_at)
            var total_seconds = Math.floor(((now - created_at) / 1000))
            var minutes = Math.floor((total_seconds / 60)) % 60
            var hours = Math.floor(total_seconds / 3600)
            var str = ""
            if(hours >= 0 && hours < 10){
              str +=  "0" + hours + ":"
            }else{
              str +=  hours + ":"
            }
            if(minutes >= 0 && minutes < 10){
              str +=  "0" + minutes
            }else{
              str +=  minutes
            }
            guest_queue.waited_time_str = str
          })
        }
      }

      function set_active_queue_setting(queue_settings){
        var active_id = LocalStorageCache.get("active_queue_setting_id")
        if(active_id){
          var queue_setting = null;
          angular.forEach(queue_settings, function(setting){
            if(setting.id == active_id){
              queue_setting = setting;
            }
          })
          $scope.choose_queue_setting(queue_setting)
        }else if($scope.queue_settings.length > 0){
          $scope.choose_queue_setting(queue_settings[0]);
        }
      }

      $scope.choose_queue_setting = function(queue_setting){
        $scope.active_history = false
        LocalStorageCache.set("active_queue_setting_id", queue_setting.id);
        $scope.active_queue_setting = queue_setting
        refresh_query()
      }

      function refresh_query(no_cache){
        if(!no_cache){
          $scope.guest_queues = LocalStorageCache.get("__branch_"+$scope.branch_id+"_queue_"+$scope.active_queue_setting.id)
        }
        $scope.page_guest_queues = PaginateService.init(GuestQueue.query, {
          branch_id: $scope.branch_id,
          queue_setting_id: $scope.active_queue_setting.id,
          "q[workflow_state_eq]": 'queueing',
          "q[s]": 'created_at asc',
          "q[m]": 'or'
        }, function(guest_queues){
          $scope.guest_queues = guest_queues
          LocalStorageCache.set("__branch_"+$scope.branch_id+"_queue_"+$scope.active_queue_setting.id, guest_queues)
          refresh_waited_time()
        })
        $scope.page_guest_queues.query()
      }

      $scope.get_history = function(){
        $scope.active_history = true
        $scope.guest_queues = LocalStorageCache.get("__branch_"+$scope.branch_id+"_queue_history")
        $scope.page_guest_queues = PaginateService.init(QueueSetting.history, {
          branch_id: $scope.branch_id,
          "q[workflow_state_not_cont]": 'queueing',
          "q[s]": 'updated_at desc',
          "q[m]": 'or'
        }, function(guest_queues){
          $scope.guest_queues = guest_queues
          LocalStorageCache.set("__branch_"+$scope.branch_id+"_queue_history", guest_queues)
        })
        $scope.page_guest_queues.query()
      }

      $scope.can_op = function(guest_queue){
        return !$rootScope.is_submiting && guest_queue && guest_queue.workflow_state === 'queueing'
      }
      $scope.can_notify = function(guest_queue){
        return guest_queue && guest_queue.workflow_state === 'queueing' && guest_queue.base_user_id
      }
      $scope.can_reprint = function(guest_queue){
        return guest_queue;
      }
      $scope.can_print_pre_order = function(guest_queue){
        return guest_queue && guest_queue.has_pre_order;
      }
      $scope.can_voice_notify = function(guest_queue){
        return guest_queue && guest_queue.workflow_state === 'queueing';
      }
      $scope.can_requeue = function(guest_queue){
        return guest_queue && (['past', 'accepted', 'canceled'].indexOf(guest_queue.workflow_state) != -1);
      }


      $scope.accept = function(guest_queue){
        if($scope.can_op(guest_queue)){
          $rootScope.is_submiting = true;
          delete_guest_queue(guest_queue);
          GuestQueue.accept({ branch_id: $scope.branch_id, queue_setting_id: guest_queue.queue_setting_id, id: guest_queue.id}, {}, function(result){
            $rootScope.is_submiting = false;
            queue_state_change(result.queue_states)
            var guest_queue = result.guest_queue;
            refresh_query(true);
            if(guest_queue.has_pre_order){
              Box.confirm("编号" + guest_queue.guest_no + "已成功入号, 是否需要打印预点菜记录?", function(){
                  $scope.print_pre_order(guest_queue);
                }, "是", null, '否')
              Box.lock_confirm_modal();
            }else{
              // Box.alert("编号" + guest_queue.guest_no + "已成功入号")
            }
          })
        }
      }

      $scope.pass = function(guest_queue){
        if($scope.can_op(guest_queue)){
          delete_guest_queue(guest_queue);
          GuestQueue.pass({ branch_id: $scope.branch_id, queue_setting_id: guest_queue.queue_setting_id, id: guest_queue.id}, {}, function(result){
            queue_state_change(result.queue_states)
            refresh_query(true);
          })
        }
      }
      $scope.requeue = function(guest_queue){
        if($scope.can_requeue(guest_queue)){
          Box.confirm("确定撤销? " + guest_queue.guest_no, function(){
            delete_guest_queue(guest_queue);
            GuestQueue.requeue({ branch_id: $scope.branch_id, queue_setting_id: guest_queue.queue_setting_id, id: guest_queue.id},{}, function(result){
              queue_state_change(result.queue_states)
            })
          })
        }
      }
      $scope.cancel = function(guest_queue){
        if($scope.can_op(guest_queue)){
          Box.confirm("确定取消排号？ "+guest_queue.guest_no, function(){
            GuestQueue.cancel({ branch_id: $scope.branch_id, queue_setting_id: guest_queue.queue_setting_id, id: guest_queue.id},{}, function(result){
              queue_state_change(result.queue_states);
              Box.alert("编号" + guest_queue.guest_no + "已成功取消")
              delete_guest_queue(guest_queue);
              refresh_query(true);
            })
          })
        }
      }

      function delete_guest_queue(guest_queue){
        var idx = $scope.guest_queues.indexOf(guest_queue)
        $scope.guest_queues.splice(idx, 1)
      }

      $scope.notify = function(guest_queue){
        if($scope.can_notify(guest_queue)){
          $scope.more_action_modal.close();
          Box.confirm("确定微信通知？ "+guest_queue.guest_no, function(){
            GuestQueue.notify({ branch_id: $scope.branch_id, queue_setting_id: guest_queue.queue_setting_id, id: guest_queue.id},{}, function(){
              $rootScope.reload()
            })
          })
        }
      }
      $scope.voice_notify = function(guest_queue){
        if($scope.can_voice_notify(guest_queue)){
          QueueFormService.set_notify($scope.active_queue_setting, guest_queue, $scope.queue_states);
          var index = $scope.queue_settings.indexOf($scope.active_queue_setting)
          QueueFormService.flick(index)
          var name = $rootScope.shop.use_shop_name_for_queue ? $rootScope.shop.name : $scope.branch.name;
          var text = guest_queue.guest_no + ' 请用餐，' + guest_queue.guest_no + ' 请用餐';
          TtsService.play(text)
        }
      }
      $scope.reprint = function(guest_queue){
        if($scope.can_reprint(guest_queue)){
          $scope.more_action_modal.close();
          if($rootScope.local_printer_configed()){
            PrintService.print_queue_bill(guest_queue)
          }else{
            GuestQueue.reprint({ branch_id: $scope.branch_id, queue_setting_id: guest_queue.queue_setting_id, id: guest_queue.id},{}, function(){})
          }
        }
      }
      $scope.print_pre_order = function(guest_queue){
        if($scope.can_print_pre_order(guest_queue)){
          if($rootScope.local_printer_configed()){
            PrintService.print_pre_order_bill(guest_queue)
          }else{
            GuestQueue.print_pre_order({ branch_id: $scope.branch_id, queue_setting_id: guest_queue.queue_setting_id, id: guest_queue.id},{}, function(){});
          }
          $scope.more_action_modal.close();
        }
      }

      function queue_state_change(queue_states){
        $scope.queue_states = queue_states;
        QueueFormService.set_queue_states(queue_states);
      }

      $scope.more_action_modal = {
        show: false,
        guest_queue: null,
        open: function(guest_queue){
          this.guest_queue = guest_queue;
          this.show = true;
        },
        reprint: function(){
          $scope.reprint(this.guest_queue)
        },
        notify: function(){
          $scope.notify(this.guest_queue)
        },
        print_pre_order: function(){
          $scope.print_pre_order(this.guest_queue)
        },
        close: function(){
          this.guest_queue = null;
          this.show = false;
        }
      }

      $scope.reprint_modal = {
        show: false,
        guest_queue: null,
        open: function(guest_queue){
          this.guest_queue = guest_queue;
          this.show = true;
        },
        can_submit: function(){ return $scope.can_reprint() && this.printer_type != null;},
        reprint: function(printer_type){
          if(printer_type === "wireless"){
            GuestQueue.reprint({ branch_id: $scope.branch_id, queue_setting_id: this.guest_queue.queue_setting_id, id: this.guest_queue.id}, {}, function(){
              $scope.reprint_modal.show = false;
            })
          }else{
            PrintService.print_queue_bill(this.guest_queue)
            $scope.reprint_modal.show = false;
          }
        },
        close: function(){this.show = false;}
      }

      $scope.print_pre_order_modal = {
        show: false,
        guest_queue: null,
        open: function(guest_queue){
          this.guest_queue = guest_queue;
          this.show = true;
        },
        can_submit: function(){ return  this.printer_type != null;},
        print: function(printer_type){
          if(printer_type === "wireless"){
            GuestQueue.print_pre_order({ branch_id: $scope.branch_id, queue_setting_id: this.guest_queue.queue_setting_id, id: this.guest_queue.id}, {}, function(){
              $scope.print_pre_order_modal.close();
              $rootScope.reload()
            })
          }else{
            PrintService.print_pre_order_bill(this.guest_queue)
            $scope.print_pre_order_modal.close();
            $rootScope.reload()
          }
        },
        close: function(){this.show = false;}
      }


      // -------queue
      $scope.guest_queue = null
      $scope.guest_nums = [1,2,3,4,5,6,7,8,9,10,11]
      $scope.more_nums = [12,13,14,15,16,17,18,19,20,21,22]
      $scope.lock_in_more_nums = false;

      function init_new_guest_queue(){
        $scope.new_guest_queue.guest_num = 2;
        $scope.new_guest_queue.phone = null;
      }
      init_new_guest_queue();

      $scope.show_queue_setting = function(){
        return $scope.branch && $scope.branch.arranging_setting_mode == "free_choice" && $scope.queue_settings.length > 0
      }

      $scope.change_guest_num = function(num){
        $scope.new_guest_queue.guest_num = num;
      }

      $scope.change_queue_setting = function(queue_setting){
        $scope.new_guest_queue.queue_setting_id = queue_setting.id;
      }

      $scope.can_create = function(){
        return !$rootScope.is_submiting && $scope.new_guest_queue.guest_num
      }

      $scope.play_guide_sound = function(){
        var guide_text = "亲爱的顾客，为避免等待，请使用微信关注我们餐厅公众号进行自助排号，排号后还可提前点菜。";
        TtsService.play(guide_text)
      }
      RefreshService.add($scope, function(){
        if($rootScope.enable_auto_play_queue_guide_sound){
          $scope.play_guide_sound()
        }
      }, 1000 * 60 * 15)
      $scope.toggle_enable_auto_play_queue_guide_sound = function(){
        $rootScope.enable_auto_play_queue_guide_sound = !$rootScope.enable_auto_play_queue_guide_sound
      }


      $scope.set_notify_number_in_advance_modal = {
        show: false,
        queue_setting_id: null,
        number: null,
        open: function(){
          this.queue_setting_id = LocalStorageCache.get("active_queue_setting_id");
          $.each($scope.queue_settings, function(index, queue_setting){
            if(queue_setting.id === LocalStorageCache.get("active_queue_setting_id")){
              $scope.queue_setting = queue_setting;
            }
          });
          this.show = true;
        },
        close: function(){
          this.queue_setting_id = null;
          this.number = null;
          this.show = false;
        },

        can_open: function(){
          if (LocalStorageCache.get("active_queue_setting_id")){
            return true;
          }else{
            return false;
          }
        },

        commit: function(number){
          if (number){
            this.number = number;
          }
          var that = this;
          QueueSetting.set_notify_number_in_advance({ branch_id: $scope.branch_id, id: this.queue_setting_id }, {notify_number_in_advance: this.number}, function(queue_settings){
            // $rootScope.reload(true);
            $scope.queue_settings = queue_settings
            that.close();
          });
        }
      };

      $scope.create = function(){
        if($scope.can_create()){
          $rootScope.is_submiting = true;
          $scope.new_guest_queue.is_local_printed = $rootScope.local_printer_configed();
          QueueSetting.create_guest_queue({branch_id: $scope.branch_id}, { guest_queue: $scope.new_guest_queue, bill_type: $rootScope.queue_bill_type()}, function(result){
            $rootScope.is_submiting = false;
            init_new_guest_queue();
            if($rootScope.local_printer_configed()){
              $rootScope.local_print_queue_bill(result.bill)
            }
            queue_state_change(result.queue_states, result)
          })
        }else{
          if(!$scope.new_guest_queue.guest_num){
            Box.alert("取号信息不完整，请完善")
          }
        }
      }

      function queue_state_change_handler(msg){
        if($rootScope.is_not_self_message(msg)){
          queue_state_change(msg.queue_states, msg);
        }
      }

      function queue_state_change(queue_states, from_msg){
        var flag = $scope.queue_states && is_queue_state_diff($scope.queue_states, queue_states);
        $scope.queue_states = queue_states;
        QueueFormService.set_queue_states(queue_states);
        if(flag){
          if($scope.active_queue_setting){
            if(from_msg && $scope.active_queue_setting.id == from_msg.queue_setting_id
              && from_msg.guest_num_at_front < 10){
              refresh_query();
            }else if(!from_msg){
              // refresh_query();
            }
          }
        }
      }

      function refresh_queue_states(){
        QueueSetting.queue_states({ branch_id: $scope.branch_id }, function(queue_states){
          queue_state_change(queue_states)
        })
      }

      function is_queue_state_diff(queue_states1, queue_states2){
        if(queue_states1 == queue_states2){
          return false;
        }
        if(queue_states1 && queue_states2 && queue_states1.length == queue_states2.length){
          var queue_state1;
          var queue_state2;
          for(var i = 0; queue_states1 && i < queue_states1.length; i ++ ){
            queue_state1 = queue_states1[i];
            queue_state2= queue_states2[i];
            if((queue_state1.count != queue_state2.count) || (queue_state1.head != queue_state2.head)){
              return true;
            }
          }
          return false;
        }
        return true;
      }

    }])
