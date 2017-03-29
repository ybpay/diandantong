CrmModules.add_controller('credits_setting')
angular.module('crm.controllers.credits_setting', []).
  controller('CreditsSettingController', ['$rootScope', '$scope','$state', 'CreditsSetting','Box',
    function($rootScope, $scope, $state, CreditsSetting, Box){
      $rootScope.page.title = "积分设置"
      $scope.goBack = function () {
        $state.transitionTo('credits_setting');
      }
      $scope.$state = $state;

      $scope.setting = {}
      CreditsSetting.get({}).$promise.then(function(resp){
        $scope.setting = resp
      })

      $scope.update = function(){
        CreditsSetting.update({}, {credits_setting: $scope.setting}).$promise.then(function(resp){
          $scope.setting = resp
          Box.toast("更新成功")
        })
      }
    }
  ])