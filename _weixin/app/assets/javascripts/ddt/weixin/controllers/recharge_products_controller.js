"use strict"

Ddt.module("ddt_app.controllers.recharge_products", []).controller('rechargeProductsController', [
  '$rootScope', '$scope', '$routeParams', 'ShopService', 'RechargeProductService', 'RechargeCartService',
  function($rootScope, $scope, $routeParams, ShopService, RechargeProductService, RechargeCartService){
    $rootScope.go("/branches/" + $rootScope.current_shop.abstract_branch_id + '/orders/recharge/new')
  }
]);



