WebposModules.add_controller('printers');
angular.module('webpos.controllers.printers', [])
  .controller('PrintersController', [
    '$scope', '$routeParams', '$interval', 'BranchService', 'PrinterService',
    function ($scope, $routeParams, $interval, BranchService, PrinterService) {
      $scope.branch_id = $routeParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch;
      });

      PrinterService.get_states($scope.branch_id, function(printers){
        $scope.printers = printers;
      });

      $scope.not_print_success_for_some_time = function(printer){
        if (printer.new_print_record_count > 0 && printer.last_print_success_at){
          var date = new Date(printer.last_print_success_at)
          var now = Date.now()
          return (now - date) > 1000 * 60; // 一分钟未出单
        } else {
          return false;
        }
      }

      $scope.format_timestamp = function(timestamp){
        return new Date(timestamp)
      }

      $scope.test_print = function(printer){
        PrinterService.test_print($scope.branch_id, printer.id);
      }

      $scope.test_print_all = function(){
        PrinterService.test_print_all($scope.branch_id);
      }

      // 一分钟自动刷新
      var refresh_interval = $interval(function(){
        $scope.reload();
      }, 60000);

      $scope.$on("$destroy", function(){
        $interval.cancel(refresh_interval)
      });
  }]);
