CrmModules.add_controller('coupon_setting_setting')
angular.module('crm.controllers.coupon_setting_setting', []).
  controller('CouponSettingSettingController', ['$rootScope', '$scope', '$mdDialog', 'CouponSetting','Box',
    function($rootScope, $scope, $mdDialog, CouponSetting, Box){
      $scope.setting = {}
      CouponSetting.get({}).$promise.then(function(resp){
        $scope.setting = resp
      })

      $scope.update = function(){
        CouponSetting.update({}, {coupon_setting: $scope.setting}).$promise.then(function(resp){
          $scope.setting = resp
          Box.toast("更新成功")
        })
      }
    }
  ])