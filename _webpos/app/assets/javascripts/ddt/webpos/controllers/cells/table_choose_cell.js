WebposModules.add_cell('table_choose')
angular.module('webpos.cells.table_choose', []).
  controller('tableChooseCell',
    ['$rootScope','$scope','$filter', 'TableZoneService','$routeParams','BranchService','TableService','NotifyService','RefreshService',
    function($rootScope, $scope, $filter, TableZoneService, $routeParams, BranchService, TableService, NotifyService, RefreshService){
      $scope.table_zones = []
      $scope.active_table_zone = null
      $scope.active_table = null
      $scope.all_tables = []
      $scope.table_filter_modal = {show: false};
      $scope.table_filter_key = "";
      $scope.last_refresh_at = undefined;
      $scope.table_list_type = "all"
      $scope.active_table_state = null
      RefreshService.add($scope, refresh_tables, 1000 * 60 * 5)
      $scope.branch_id = $routeParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
        TableZoneService.query($scope.branch_id, function(table_zones){
          $scope.table_zones = table_zones;
          if($scope.table_zones.length == 0){
            load_tables()
          }else{
            after_load_tables()
            refresh_tables();
          }
        })
      })

      var state_names = {
        idle: '空闲',
        opened: '已开台',
        ordered: '已下单',
        check_outing: '结帐中',
        paid: '已支付'
      };

      $scope.change_table_list = function(key, value){
        $scope.table_list_type = key
        $scope.clear_table_filter_key()
        $rootScope.set_cache("table_list_type", key);
        $scope.active_table_zone = null
        $scope.active_table_state = null
        if(key == "all"){
        }else if(key == "table_zone"){
          $scope.active_table_zone = value
          $rootScope.set_cache("active_table_zone_id", $scope.active_table_zone.id);
        }else if(key == "table_state"){
          $scope.table_filter_modal.show = false;
          $scope.active_table_state = value
          $scope.state_name = state_names[$scope.active_table_state]
          $rootScope.set_cache("active_table_state", $scope.active_table_state);
        }else if(key == "table_state_inq"){
          $scope.table_filter_modal.show = false;
          $scope.table_states_queue = value
          $scope.state_name = '非空闲';
          $rootScope.set_cache("table_states_queue", $scope.table_states_queue);
        }
      }

      $scope.choose_table = function(table){
        $rootScope.set_cache("active_table_id", table.id)
        $scope.active_table = table
        $scope.$emit("event:choose_table", table)
      }

      $scope.reset_table = function(){
        $rootScope.set_cache("active_table_id", null)
        $scope.active_table = null
        $scope.$emit("event:choose_table:reset")
      }

      var clear_state_change_listener = $scope.$on('event:table:state_change', function(event, table){
        refresh_tables()
      })

      var clear_change_table_listener = $scope.$on('event:table:action:change_table', function(event){
        $scope.change_table_list('table_state', 'idle')
      })


      var clear_merge_table_listener = $scope.$on('event:table:action:merge_table', function(event){
        $scope.change_table_list('table_state', 'ordered')
      })

      function load_tables(){
        TableZoneService.query($scope.branch_id, function(table_zones){
          $scope.table_zones = table_zones
          after_load_tables()
        })
      }

      function refresh_tables(){
        var date_str = undefined;
        date_str = $filter('date')(get_last_refresh_at_with_max(), "yyyy-MM-dd HH:mm:ss")
        TableService.get_changed_tables($scope.branch_id, date_str, function(tables){
          angular.forEach(tables, function(new_table){
            /* update all_tables */
            $scope.all_tables = update_table($scope.all_tables, new_table)
            /* update table_zone's tables */
            angular.forEach($scope.table_zones, function(table_zone){
              if(new_table.table_zone_id == table_zone.id){
                table_zone.tables = update_table( (table_zone.tables || []), new_table)
              }
            })
          })
          $scope.active_table = find_object($scope.all_tables, $rootScope.get_cache("active_table_id"))
          if($scope.active_table && $scope.active_table.workflow_state != "idle"){
            $scope.choose_table($scope.active_table)
          }
        })
      }

      function update_table(table_collection, new_table){
        var idx = _.findIndex(table_collection, function(o){ return o.id == new_table.id})
        if(idx == -1){
          table_collection.push(new_table)
        }else{
          table_collection[idx] = new_table
        }
        return table_collection
      }

      function after_load_tables(){
        $scope.all_tables = []
        angular.forEach($scope.table_zones, function(table_zone){
          $scope.all_tables = $scope.all_tables.concat(table_zone.tables)
        })
        $scope.table_list_type = $rootScope.get_cache("table_list_type") || 'all'
        switch($scope.table_list_type){
          case "all":
            $scope.change_table_list("all")
            break;
          case "table_zone":
            var table_zone_id = $rootScope.get_cache("active_table_zone_id")
            if(table_zone_id){
              var table_zone = find_object($scope.table_zones, table_zone_id);
              if(table_zone){
                $scope.change_table_list("table_zone", table_zone)
              }
            }
            break;
          case "table_state":
            var table_state = $rootScope.get_cache("active_table_state")
            if(table_state){
              $scope.change_table_list("table_state", table_state)
            }
            break;
          case 'table_state_inq':
            var table_states_queue = $rootScope.get_cache("table_states_queue");
            if(table_states_queue){
              $scope.change_table_list('table_state_inq', table_states_queue);
            }
            break;
        }
        $scope.active_table = find_object($scope.all_tables, $rootScope.get_cache("active_table_id"))
      }

      function find_object(objects, id){
        var result = null;
        angular.forEach(objects, function(object){
          if(object.id == id){
            result = object;
          }
        })
        return result;
      }

      function get_last_refresh_at_with_max(){
        if($scope.all_tables.length == 0){return new Date(0)}
        var max_time = new Date(_.max(_.map($scope.all_tables, function(table){return Date.parse(table.updated_at)})))
        $scope.last_refresh_at = max_time;
        return $scope.last_refresh_at; //返回最小时间戳前的60s
      }

      $scope.table_classes = function(table) {
        var classes = [table.workflow_state];
        if (table == $scope.active_table) {
          classes.push("table-active");
        }
        return classes;
      };

      NotifyService.set_message_hander_in_scope($scope, "TABLE_NOTIFICATION", function(message){
        console.log(message);
        if(message.branch_id == $scope.branch_id){
          refresh_tables();
        }
      });
      NotifyService.set_message_hander_in_scope($scope, 'TABLE_CHECK_OUT', function(msg){
        if($rootScope.is_not_self_message(msg)){
          refresh_tables()
        }
      })
      NotifyService.set_message_hander_in_scope($scope, 'TABLE_CANCEL_CHECK_OUT', function(msg){
        if($rootScope.is_not_self_message(msg)){
          refresh_tables()
        }
      })
      NotifyService.set_message_hander_in_scope($scope, 'TABLE_ANTI_SETTLEMENT', function(msg){
        refresh_tables()
      })

      $scope.clear_table_filter_key = function(){
        $scope.table_filter_key = "";
      }

      $scope.count_by_state = function(states){
        return $scope.all_tables.filter(function(table){
          return states.indexOf(table.workflow_state) > -1
        }).length ;
      }

      $scope.display_tables = function(){
        var tables = []
        switch($scope.table_list_type){
          case 'all':
            tables = $scope.all_tables
            break;
          case 'table_zone':
            tables = ($scope.active_table_zone ? $scope.active_table_zone.tables||[] : [])
            break;
          case 'table_state':
            tables = $scope.all_tables.filter(function(table){return table.workflow_state == $scope.active_table_state})
            break;
          case 'table_state_inq':
            tables = $scope.all_tables.filter(function(table){ return $scope.table_states_queue.indexOf(table.workflow_state) > -1})
            break;
        }
        var result = [];
        result = result.concat(tables.filter(function(table){ return !$scope.table_filter_key || table.name.toLowerCase().indexOf($scope.table_filter_key.toLowerCase()) == 0}))
        result = result.concat(tables.filter(function(table){ return $scope.table_filter_key && table.name.toLowerCase().indexOf($scope.table_filter_key.toLowerCase()) > 0}))
        return result;
      }

      // 自动获取焦点
      $rootScope.focus(".table_filter_key input")

      var unbind_hotkey_table_filter = $rootScope.bind_key('enter', function(){
        if($scope.table_filter_key){
          var tables = $scope.display_tables();
          if(tables.length == 1){
            if($scope.active_table && $scope.active_table.id == tables[0].id){
              emit_settle();
            }else{
              $scope.choose_table(tables[0])
            }
          }else if($scope.active_table){
            emit_settle();
          }
        }else if($scope.active_table){
          emit_settle();
        }
      })

      var emit_settle = function(){
        $scope.$emit("event:settle_table", $scope.active_table)
      }

      $scope.$on("$destroy", function(){
        clear_state_change_listener()
        clear_change_table_listener()
        clear_merge_table_listener()
        unbind_hotkey_table_filter()
      })

    }])
