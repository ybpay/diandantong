CrmModules.add_controller('recharge_setting')
angular.module('crm.controllers.recharge_setting', []).
  controller('RechargeSettingController', ['$rootScope','$scope','VipInfoSetting', '$mdDialog', 'Box',
    function($rootScope, $scope, VipInfoSetting, $mdDialog, Box){
      $scope.setting = {}
      VipInfoSetting.get({}).$promise.then(function(resp){
        $scope.setting = resp
      })

      $scope.update = function(){
        VipInfoSetting.update({}, {vip_info_setting: $scope.setting}).$promise.then(function(resp){
          $scope.setting = resp
          Box.toast("更新成功")
        })
      }
    }
  ])