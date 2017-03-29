CrmModules.add_controller('vip_setting_info_setting')
angular.module('crm.controllers.vip_setting_info_setting', []).
  controller('VipSettingInfoSettingController', ['$rootScope', '$scope', '$mdDialog', 'VipInfoSetting','Box',
    function($rootScope, $scope, $mdDialog, VipInfoSetting, Box){
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