Ddt.module('ddt_app.controllers.sign_record', [])
  .controller('signRecordsController', [
    '$scope', '$rootScope', 'SignRecordService', 'UserService',
    function ($scope, $rootScope, SignRecordService, UserService) {
      $rootScope.title = "每日签到"
      $scope.user = null
      $scope.load_time = new Date()

      function init_sign_msg(user){
        $scope.user = user
        console.log($scope.user.sign_history)
        $scope.item_groups = group_in(user.sign_history, 4);
      }

      UserService.refresh(init_sign_msg)

      $scope.can_sign = function(){
        return $scope.user && !$scope.user.today_signed
      }

      $scope.sign = function(){
        if($scope.can_sign()){
          SignRecordService.sign(function(sign_record){
            UserService.refresh(init_sign_msg)
          })
        }
      }
  }])
