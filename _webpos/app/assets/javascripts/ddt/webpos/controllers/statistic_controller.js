WebposModules.add_controller('statistic');
angular.module('webpos.controllers.statistic',[]).
  controller('statisticController',['$rootScope', '$scope', 'StatisticService','Branch',
    function($rootScope, $scope, StatisticService, Branch){
      $scope.statistic_type = 'product_sales'; // ['product_sales', 'order_quantity']
      $scope.time_filter = 'today'; // ['today', 'yesterday', 'last_week', 'this_week']
      $scope.result = {}
      Branch.query({}).$promise.then(function(branches){
        $scope.branches = branches
        if(branches.length > 0){
          $scope.change_active_branch(branches[0])
        }
      })

      $scope.change_active_branch = function(branch){
        $scope.active_branch = branch
      }

      $scope.change_statistic_type = function (type){
        $scope.statistic_type = type;
      }

      $scope.change_time_filter = function(time_filter){
        $scope.time_filter = time_filter
      }

      var clear_watch_active_branch = $scope.$watch("active_branch", reload_statistic)
      var clear_watch_statistic_type = $scope.$watch("statistic_type", reload_statistic)
      var clear_watch_time_filter = $scope.$watch("time_filter", reload_statistic)
      $scope.$on("$destroy", function(){
        clear_watch_active_branch()
        clear_watch_statistic_type()
        clear_watch_time_filter()
      })

      function reload_statistic(){
        if($scope.active_branch && $scope.time_filter){
          var params = {
            time_filter: $scope.time_filter,
            branch_id: $scope.active_branch.id
          };
          if($scope.statistic_type == 'product_sales'){
            StatisticService.product_sales(params, function(result){
              $scope.result = result;
            })
          }else if($scope.statistic_type == 'order_quantity'){
            StatisticService.order_quantity(params, function(result){
              $scope.result = result;
            })
          }
        }
      }

      $scope.is_empty = function(){
        var size = Object.keys($scope.result).length
        return size == 2; // $promise $resolved
      }

    }]);
