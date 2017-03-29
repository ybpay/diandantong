WebposModules.add_controller('login')
angular.module('webpos.controllers.login', []).
  controller('LoginController', ['$rootScope', '$scope',
    function($rootScope, $scope){
      if($rootScope.account){
        $rootScope.go('/')
      }else{
        $rootScope.go_path('/webpos#/accounts/sign_in')
      }
    }])
