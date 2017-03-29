"use strict"

Ddt.module("ddt_app.controllers.invoice",[]).controller('invoiceController', [
  '$rootScope', '$scope', '$routeParams','InvoiceService',
  function($rootScope, $scope, $routeParams, InvoiceService){
    $rootScope.title = "索要发票"
    $scope.branch_id = $routeParams.branch_id;
    $scope.order_type= $routeParams.order_type;
    $scope.order_id  = $routeParams.order_id;
    $scope.invoice = {
      payer: 'personal',
      title: null,
      order_id: $scope.order_id
    };

    $scope.change_payer = function(payer){
      $scope.invoice.payer = payer;
    }

    $scope.can_submit = function(){
      if($scope.invoice.payer == 'company' && ($scope.invoice.title == null || $scope.invoice.title == "")){return false;}
      return true;
    }

    $scope.submit = function(){
      if($scope.can_submit()){
        InvoiceService.create($scope.branch_id, $scope.order_id, $scope.invoice, function(){
          $rootScope.go("/branches/" + $scope.branch_id + "/orders/" + $scope.order_type + "/" + $scope.order_id);
        })
      }else{
        $rootScope.$emit("events:receive_errors", "请填写公司名称");
      }

    }

  }])
