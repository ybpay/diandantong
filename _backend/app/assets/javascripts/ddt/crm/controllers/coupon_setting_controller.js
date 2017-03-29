CrmModules.add_controller('coupon_setting')
angular.module('crm.controllers.coupon_setting', []).
  controller('CouponSettingController', ['$rootScope', '$scope','$state',
    function($rootScope, $scope, $state){
      $rootScope.page.title = "卡券设置"
      $scope.goBack = function () {
        $state.transitionTo('coupon_setting.coupon_versions');
      }
      $scope.$state = $state;
    }
  ])