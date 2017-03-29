Ddt.controller('orderAppendItemableConfirmController', [
    '$rootScope', '$scope', '$location', '$routeParams', 'BranchService', 'BaseOrderService','AppendItemableService', 'BaseCartService',
    function($rootScope, $scope, $location, $routeParams, BranchService, BaseOrderService, AppendItemableService, BaseCartService){

      $rootScope.title = '加菜确认';
      $scope.branch_id = $routeParams.branch_id
      $scope.order_type = $routeParams.order_type
      $scope.order_id = $routeParams.order_id

      $scope.branch = null

      BranchService.get({id: $scope.branch_id}, function (branch) {
        $scope.branch = branch;
      });

      BaseOrderService.get($scope.order_type, $scope.branch_id, $scope.order_id, function (order) {
        $scope.order = order;
        if($location.search().from_table_cart){
          // from_cart
          $scope.cart = AppendItemableService.init($scope.order);
          BaseCartService.get("eat_in_hall", $scope.branch_id, function(table_cart){
            angular.forEach(table_cart.line_items, function(line_item){
              for(var i=0;i<line_item.quantity;i++){
                AppendItemableService.append_itemable(line_item, "", function(cart){ $scope.cart = cart })
              }
            })
          })
        }else{
          $scope.cart = AppendItemableService.get_cart();
        }
      })

      $scope.add_itemable = function(itemable){
        AppendItemableService.append_itemable(itemable, itemable.note, function(cart){
          $scope.cart = cart;
        })
      }

      $scope.remove_itemable = function(itemable){
        AppendItemableService.remove_itemable(itemable, itemable.note, function(cart){
          $scope.cart = cart;
        })
      }

      $scope.can_submit = function(){
        return $scope.cart && $scope.cart.item_count > 0 && ($scope.cart.total > 0 || ($scope.branch && $scope.branch.can_place_when_zero))
      }

      $scope.submit = function(){
        if($scope.can_submit()){
          var variant_ids = $scope.order.all_line_items.map(function(line_item){
              return line_item.itemable_id;
            })
          var names = $scope.cart.line_items.map(function(cart_line_item){
            var str = [cart_line_item.name]
            if(cart_line_item.note ){ 
              str.push("[" + cart_line_item.note + "]")
            }
            str.push(" * "+ cart_line_item.quantity)
            if (variant_ids.indexOf(cart_line_item.itemable_id) > -1){ 
              str.push("<a class='red'>已点过</a>") 
            }
            return str.join()
          }).join("<br/>");
          names += "<br/>注意，一旦确认后，系统会立即通知厨房进行烹饪。";
          $rootScope.confirm("确认追加以下菜品？", names, function(){
            AppendItemableService.submit($scope.branch_id, $scope.order_type, $scope.order_id, function(){
              $rootScope.go_page('order', "/branches/" + $scope.branch_id + "/orders/" + $scope.order_type + "/" + $scope.order_id)
            })
          })
        }
      }

}])
