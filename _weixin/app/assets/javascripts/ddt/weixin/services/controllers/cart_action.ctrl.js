Ddt.module("ddt_app.services.cart_action", [])
  .factory('CartAction', [
    '$rootScope', '$routeParams', 'SnapCartService', 'BaseCartService', 'BranchService',
    function($rootScope, $routeParams, SnapCartService, BaseCartService, BranchService) {
      function action($scope){
        $scope.branch_id = $scope.branch_id || $routeParams.branch_id
        $scope.cart_type = $scope.cart_type || $scope.order_type || 'delivery'
        BranchService.get({id: $scope.branch_id}, function(branch){
          $scope.branch = branch
        })

        $scope.add_itemable = function(itemable, is_snap){
          if($scope.need_check_stock(itemable)){
            var has_error = false;
            if(typeof(itemable.quantity) == 'undefined' && itemable.stock_quantity - 1 < 0)  has_error = true;
            if(itemable.stock_quantity - itemable.quantity <= 0)  has_error = true;
            if(has_error){
              $scope.$emit("events:receive_errors", '该产品只剩下 '+itemable.stock_quantity+'份');
              return;
            }
          }

          is_snap = typeof is_snap !== 'undefined' ? is_snap : true;
          if(is_snap){
            SnapCartService.add_itemable($scope.cart_type, $scope.branch_id, itemable, function(cart){
              $rootScope.$broadcast("cart:snap:change", cart)
            })
          }else{
            BaseCartService.add_itemable($scope.cart_type, $scope.branch_id, itemable, function(cart){
              // console.log(cart)
              SnapCartService.set_cart($scope.cart_type, $scope.branch_id, cart)
              $rootScope.$broadcast("cart:change", cart)
            })
          }
        }

        $scope.remove_itemable = function(itemable, is_snap){
          is_snap = typeof is_snap !== 'undefined' ? is_snap : true;
          if(is_snap){
            SnapCartService.remove_itemable($scope.cart_type, $scope.branch_id, itemable, function(cart){
              // console.log(cart)
              $rootScope.$broadcast("cart:snap:change", cart)
            })
          }else{
            BaseCartService.remove_itemable($scope.cart_type, $scope.branch_id, itemable, function(cart){
              // console.log(cart)
              SnapCartService.set_cart($scope.cart_type, $scope.branch_id, cart)
              $rootScope.$broadcast("cart:change", cart)
            })
          }
        }

        $scope.stock_of = function(itemable){
          if(itemable.quantity == undefined){
           return itemable.stock_quantity;
          }
          return itemable.stock_quantity - itemable.quantity;
        }

        $scope.can_minus = function(itemable){
          return itemable.quantity > 0
        }

        $scope.can_plus = function(itemable){
          if($scope.need_check_stock(itemable)){
            return $scope.stock_of(itemable) > 0 ? true : false;
          }
          return true;
        }

        $scope.need_check_stock = function(itemable){
          return ($scope.check_stock || ($scope.branch && $scope.branch.check_stock)) && itemable.itemable_type == "Ddt::Variant"
        }

      }

      return {
        action: action
      };
  }])
