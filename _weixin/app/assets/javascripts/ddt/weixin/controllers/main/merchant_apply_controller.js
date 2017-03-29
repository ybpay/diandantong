"use strict"
Ddt.controller('merchantApplyController', [
  '$rootScope', '$location', '$scope', 'MerchantApplyService',
  function($rootScope, $location, $scope, MerchantApplyService) {
    $rootScope.title = '入驻申请';

    $scope.merchantApply = {};

    $scope.refresh = function () {
      MerchantApplyService.get({}, function(data) {
        $scope.merchantApply = data;
      });
    };

    $scope.refresh();

    $scope.can_apply = function() {
      return $scope.merchantApply.phone && $scope.merchantApply.note;
    };

    $scope.apply = function() {
      if ($scope.can_apply()) {
        MerchantApplyService.save($scope.merchantApply, function() {
          $scope.refresh();
          $rootScope.$emit("events:success_info", "申请提交成功");
        });
      } else {
        $rootScope.$emit("events:success_info", "请先填写信息后再提交");
      }
    };

    $scope.cancel = function() {
      MerchantApplyService.cancel({}, function() {
        $scope.refresh();
        $rootScope.$emit("events:success_info", "申请已取消")
      });
    };

  }
]);
