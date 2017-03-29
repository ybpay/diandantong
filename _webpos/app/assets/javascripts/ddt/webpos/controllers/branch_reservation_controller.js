WebposModules.add_controller('branch_reservation')
angular.module('webpos.controllers.branch_reservation', []).
  controller('branchReservationController',
    ['$rootScope','$scope','$location','$routeParams','BranchService','ReservationDateService','TableZoneService','TableService','ReservationInfoService', 'ReservationOrderService',
    function($rootScope, $scope, $location, $routeParams, BranchService, ReservationDateService, TableZoneService, TableService,ReservationInfoService, ReservationOrderService){
      $scope.reservation_dates = []
      $scope.table_zones = []
      $scope.active_date = null
      $scope.active_time_point = null
      $scope.active_table = null
      $scope.reservation_info = {}
      $scope.reservation_info.name = ""
      $scope.reservation_info.phone= ""
      $scope.reservation_info.gender = "male"
      $scope.reservation_info.note = ""
      $scope.gender_collection = [{ value: 'male', label: '先生'}, { value: 'female', label: '女士'}]

      var number = $location.search().caller_number
      if(number){
        ReservationInfoService.search(number, function(infos){
          if(infos.length > 0){
            $scope.reservation_info.name   = infos[0].name
            $scope.reservation_info.phone  = infos[0].phone
            $scope.reservation_info.gender = infos[0].gender
          }else{
            $scope.reservation_info.phone = number
          }
        })
      }

      $scope.branch_id = $routeParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
        if($scope.branch.use_reservation_setting){
          var max_reservation_days = 7;
          if($scope.branch.reservation_setting){
            max_reservation_days = $scope.branch.reservation_setting.max_reservation_days;
          }
          $scope.reservation_dates = ReservationDateService.get(max_reservation_days)
          $scope.active_date = $scope.reservation_dates[0]
          TableZoneService.with_reservation_time_points($scope.branch_id, function(table_zones){
            $scope.table_zones = table_zones
          })
        }
      })

      $scope.change_active_date = function(date){
        $scope.active_date = date
        $scope.active_time_point = null
        $scope.active_table = null
      }

      $scope.change_active_time_point = function(time_point){
        $scope.active_time_point = time_point
        $scope.active_table = null
        TableService.get_reservation_tables($scope.branch_id, $scope.active_date.value, $scope.active_time_point.id, function(tables){
          $scope.active_time_point.tables = tables
        })
      }


      $scope.select_table = function(table){

        if($scope.is_disabled($scope.active_time_point) && table.can_reservation){
          $rootScope.alert(disabled_reason())
          return;
        }
        $scope.active_table = table
      }

      $scope.is_disabled = function(time_point){
        //today
        if($scope.active_date == null || time_point == null){return false}
        if($scope.active_date.position == 0 && !time_point.can_order_today){
          return true
        }
        return time_point.remain_table_counts[$scope.active_date.position] <= 0
      }
      var disabled_reason = function(){
        if($scope.active_date.position == 0 && !$scope.active_time_point.can_order_today){
          return "预订时间已过"
        }
        if($scope.active_time_point.remain_table_counts[$scope.active_date.position] <= 0){
          return "当前时间点已定满"
        }
      }

      var is_name_valid = function(){ return $scope.reservation_info.name != null && $scope.reservation_info.name != ""}
      var is_phone_valid= function(){ return $scope.reservation_info.phone!= null && $scope.reservation_info.phone!= ""}
      $scope.can_submit = function(){
        // edit reservation info
        if($scope.active_table && $scope.active_table.reservation_info){
          return is_name_valid() && is_phone_valid();
        }
        return !$scope.is_disabled($scope.active_time_point) && is_name_valid() && is_phone_valid();
      }

      $scope.submit = function(){
        if(!$rootScope.is_submiting){
          if($scope.active_table.reservation_info){
            edit_reservation_info();
          }else{
            if($scope.can_submit()){
              place_reservation_order();
            }else{
              var errors = []
              if(!is_name_valid()){ errors.push("姓名不能为空")}
              if(!is_phone_valid()){errors.push("电话不能为空")}
              if($scope.is_disabled($scope.active_time_point)){errors.push(disabled_reason())}
              $rootScope.alert(errors.join("<br/>"))
            }
          }
        }
      }

      var place_reservation_order = function(){
        $rootScope.is_submiting = true;
        ReservationOrderService.create($scope.branch_id, {
          table_id: $scope.active_table.id,
          reservation_date: $scope.active_date.value,
          reservation_time_point_id: $scope.active_time_point.id,
          name:   $scope.reservation_info.name,
          phone:  $scope.reservation_info.phone,
          gender: $scope.reservation_info.gender,
          note:   $scope.reservation_info.note,
          is_local_printed: $rootScope.local_printer_configed(),
          bill_type: $rootScope.order_bill_type()
        }, function(result){
          update_remain_table_count();
          $rootScope.is_submiting = false;
          $scope.active_table.can_reservation = false;
          $scope.active_table.reservation_info = $scope.reservation_info;
          $scope.active_table.reservation_info.order_id = result.id;
          $scope.reservation_info = {};
          $scope.active_table = null;
          var bill = result.bill;
          var order = result;
          var alert_success = function(){$rootScope.alert("预订订单提交成功");}
          if($rootScope.local_printer_configed()){
            $rootScope.local_print_order_bill(bill, false)
            alert_success();
          }else if($scope.branch.webpos_autoprinter_configed){
            alert_success();
          }else{
            $rootScope.confirm("订单提交成功, 您是否要打印该订单?", function(){
              $rootScope.wire_print_order_bill(order)
            })
          }
        });
      }

      var edit_reservation_info = function(){
        $rootScope.is_submiting = true;
        ReservationOrderService.edit_reservation_info($scope.branch_id, $scope.active_table.reservation_info.order_id, {
          name:   $scope.active_table.reservation_info.name,
          phone:  $scope.active_table.reservation_info.phone,
          gender: $scope.active_table.reservation_info.gender,
          note:   $scope.active_table.reservation_info.note
        }, function(result){
          $rootScope.is_submiting = false;
          $scope.reservation_info = {};
          $scope.active_table = null;
          hide_modal();
          $scope.alert("信息更改成功")
        })
      }

      var update_remain_table_count = function(){
        $scope.active_time_point.remain_table_counts[$scope.active_date.position] -= 1
      }

    }])
