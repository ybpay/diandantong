CrmModules.add_controller('home')
angular.module('crm.controllers.home', []).
  controller('HomeController', ['$rootScope', '$scope',
    function($rootScope, $scope){
      $rootScope.page.title = "首页"
    }
  ])