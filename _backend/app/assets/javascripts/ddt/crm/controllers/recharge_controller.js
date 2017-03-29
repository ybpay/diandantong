CrmModules.add_controller('recharge')
angular.module('crm.controllers.recharge', []).
  controller('RechargeController', ['$rootScope', '$scope','$state',
    function($rootScope, $scope, $state){
      $rootScope.page.title = "充值设置"
      $scope.goBack = function () {
        $state.transitionTo('recharge.products');
      }
      $scope.$state = $state;
    }
  ])