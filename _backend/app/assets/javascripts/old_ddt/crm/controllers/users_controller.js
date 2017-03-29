CrmModules.add_controller('users')
angular.module('crm.controllers.users', []).
  controller('UsersController', ['$rootScope', '$scope','$state',
    function($rootScope, $scope, $state){
      $rootScope.page.title = "用户列表"
      $scope.goBack = function () {
        $state.transitionTo('users.index');
      }
      $scope.$state = $state;
    }
  ])