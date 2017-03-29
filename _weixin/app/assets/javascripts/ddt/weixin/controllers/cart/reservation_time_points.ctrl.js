Ddt.controller('reservationTimePointsController',
  ['$rootScope', '$routeParams', '$scope', 'BranchService', 'TableZoneService', 'ReservationDateService', 'ReservationCartService', 'SnapCartService',
  function($rootScope, $routeParams, $scope, BranchService, TableZoneService, ReservationDateService, ReservationCartService, SnapCartService){
    $rootScope.title = '预订时间';

    $scope.branch_id = $routeParams.branch_id
    $scope.branch = null
    $scope.reservation_dates = 0
    $scope.active_date = null
    $scope.table_zones = []
    $scope.enable = false

    BranchService.get({ id: $scope.branch_id }, function(branch){
      $scope.branch = branch
      $scope.reservation_dates = ReservationDateService.get($scope.branch.reservation_setting.max_reservation_days)
      $scope.active_date = $scope.reservation_dates[0]
      TableZoneService.query($scope.branch_id, function(table_zones){
        $scope.table_zones = table_zones
        $scope.enable = true
      })
    })


    $scope.select_date = function(date){
      $scope.active_date = date
    }

    $scope.show_date = function(date){
      return Math.abs(date.position - $scope.active_date.position) <= 1
    }

    $scope.go_new_reservation_order = function(reservation_time_point){
      if(!$scope.is_sale_out(reservation_time_point)){
        ReservationCartService.update_reservation_info($scope.branch_id, {
          reservation_date: $scope.active_date.value,
          reservation_time_point_id: reservation_time_point.id
        }, function(cart){
          SnapCartService.set_cart('reservation', $scope.branch_id, cart)
          $rootScope.go("/branches/"+ $scope.branch_id + "/orders/reservation/new")
        })
      }
    }

    $scope.is_sale_out = function(time_point){
      if($scope.active_date == null){return true;}
      return time_point.is_sale_outs[$scope.active_date.position]
    }

}])
