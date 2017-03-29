"use strict"

Ddt.controller('censorReportController', [
  '$rootScope', '$location', '$scope', 'CensorReportService',
  function ($rootScope, $location, $scope, CensorReportService) {
    $rootScope.title = '举报';
    $scope.data = {};
    $scope.report = function(){
      CensorReportService.report($scope.data.title, $scope.data.desc, function(){
        $scope.visible = false;
        $scope.data = {};
        $rootScope.$emit("events:success_info", "提交成功，谢谢您的反馈");
        $location.path("/");
      });
    }
  }]);
