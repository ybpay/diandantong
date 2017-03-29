Ddt.controller('tableController',
  ['$rootScope', '$scope', '$routeParams', 'TableService',
    function($rootScope, $scope, $routeParams, TableService){
      $scope.active_guest_num = -1;
      $scope.guest_nums = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]

      $scope.change_guest_num = function(guest_num){
        $scope.active_guest_num = guest_num;
      }

      $scope.open_table = function(){
        if($scope.active_guest_num > 0){
          TableService.open($routeParams.branch_id, $routeParams.table_id, $scope.active_guest_num, function(){
            $rootScope.go('/branches/'+$routeParams.branch_id+'/products/eat_in_hall')
          })
        }else{
          $rootScope.alert('请选择人数');
        }

      }

    }
  ])
