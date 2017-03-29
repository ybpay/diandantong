WebposModules.add_controller('branch_payment')
angular.module('webpos.controllers.branch_payment', []).
  controller('branchPaymentController',
    ['$rootScope','$scope','$routeParams','BranchService','BaseOrderService', 'PaymentOrderService',
    function($rootScope, $scope, $routeParams, BranchService, BaseOrderService, PaymentOrderService){
      $scope.branch_id = $routeParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
      })

      $scope.amount = null
      $scope.note = ""

      $scope.order_type = "payment"

      $rootScope.focus('.payment-amount input')

      $scope.can_submit = function(){
        return !$rootScope.is_submiting && $scope.amount && parseFloat($scope.amount) > 0
      }

      $scope.submit = function(){
        if($scope.can_submit()){
          $rootScope.is_submiting = true
          PaymentOrderService.create($scope.branch_id, {
            amount: $scope.amount,
            note: $scope.note
          }, function(resp){
            $rootScope.is_submiting = false
            $rootScope.go("/branches/" + $scope.branch_id + "/orders/" + resp.order.id + "/settle/"+resp.order.type_str)
          })
        }
      }
    }])
