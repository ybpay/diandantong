"use strict"

Ddt.module("ddt_app.controllers.exchange_codes", []).controller('exchangeCodeController', [
  '$rootScope', '$scope', '$routeParams', 'ExchangeCodeService',
  function($rootScope, $scope, $routeParams, ExchangeCodeService){
    $rootScope.title = '兑换码'
    $scope.exchange_code_id = $routeParams.exchange_code_id
    $scope.permissions = []

    ExchangeCodeService.get($scope.exchange_code_id, function(exchange_code) {
      $scope.exchange_code = exchange_code
      $scope.get_qrcode();
    });

    ExchangeCodeService.get_permissions($scope.exchange_code_id, function(result) {
      $scope.permissions = result.permissions
      if(!$scope.can_show()){
        $rootScope.$emit("events:receive_errors", '您没有权限查看该兑换码!');
        $rootScope.go("/")
      }
    });

    $scope.can_show = function(){
      return $scope.permissions && $scope.permissions.indexOf("show") >= 0
    }

    $scope.can_exchange = function(){
      return $scope.permissions && $scope.permissions.indexOf("exchange") >= 0 && $scope.exchange_code.state == 'pending'
    }

    $scope.can_get_qrcode = function(){
      return $scope.permissions && $scope.permissions.indexOf("get_qrcode") >= 0 && $scope.exchange_code.state == 'pending'
    }

    $scope.exchange = function(){
      ExchangeCodeService.exchange($scope.exchange_code_id, function() {
        $rootScope.reload()
      });
    }

    $scope.get_qrcode = function(){
      ExchangeCodeService.get_qrcode($scope.exchange_code_id, function(qrcode) {
        $scope.qrcode = qrcode;
        $scope.change_qrcode("scan_gun");
      });
    }

    $scope.change_qrcode = function(key){
      $scope.key = key;
      $scope.current_qrcode_hint = key == "wechat" ? "商家微信扫码":"商家扫码抢扫码";
    }
  }
]);
