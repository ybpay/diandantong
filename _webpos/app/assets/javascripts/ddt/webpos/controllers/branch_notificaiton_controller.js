WebposModules.add_controller('branch_notification')
angular.module('webpos.controllers.branch_notification', []).
  controller('branchNotificationController',
    ['$rootScope','$scope', '$routeParams','BranchService','NotificationService','RefreshService',
    function($rootScope, $scope, $routeParams, BranchService, NotificationService,RefreshService){
      $scope.notifications = []
      $scope.branch_id = $routeParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
        load_notifications();
        RefreshService.add($scope, load_notifications, 1000)
      })

      function load_notifications(){
        $scope.notifications = NotificationService.get($scope.branch_id)
      }

      $scope.clear = function(){
        NotificationService.clear($scope.branch_id)
        $scope.notifications = []
      }

      $scope.remove = function(msg){
        NotificationService.remove($scope.branch_id, msg)
      }

    }])
