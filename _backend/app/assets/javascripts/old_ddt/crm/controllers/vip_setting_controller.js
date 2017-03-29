CrmModules.add_controller('vip_setting')
angular.module('crm.controllers.vip_setting', []).
  controller('VipSettingController', ['$rootScope', '$scope','$state',
    function($rootScope, $scope, $state){
      $rootScope.page.title = "会员设置"
      $scope.goBack = function () {
        $state.transitionTo('vip_setting.index');
      }
      $scope.$state = $state;
    }
  ])