WebposModules.add_cell('subtractable_choose');
angular.module('webpos.cells.subtractable_choose', []).
  controller('subtractableChooseCell',
    ['$rootScope', '$scope', '$routeParams', 'BaseOrderService', 'ShopService',
    function($rootScope, $scope, $routeParams, BaseOrderService, ShopService) {

      $scope.branch_id = $routeParams.branch_id;
      $scope.order = null;
      $scope.active_line_item = null;

      var clear_subtract_itemable_listener = $scope.$on("event:subtract_itemable:order", function(event, order) {
        $scope.order = order;
        BaseOrderService.active_line_items($scope.order.type_str, $scope.branch_id, $scope.order.id, function(active_line_items) {
          $scope.line_items = active_line_items;
          angular.forEach($scope.line_items, function(line_item){ line_item.subtract_quantity = 0 })
        });
      });
      $scope.$on("$destroy", function(){
        clear_subtract_itemable_listener()
      })

      $scope.change_active_line_item = function(line_item) {
        $scope.active_line_item = line_item;
      };

      $scope.can_plus = function(line_item) {
        return line_item && line_item.subtract_quantity > 0;
      };

      $scope.can_minus = function(line_item) {
        return line_item && line_item.active_quantity > line_item.subtract_quantity;
      }

      $scope.add = function(line_item) {
        if ($scope.can_plus(line_item)) {
          line_item.subtract_quantity -- ;
        }
      };

      $scope.remove = function(line_item) {
        if ($scope.can_minus(line_item)) {
          line_item.subtract_quantity++;
        }
      };

      $scope.subtractables = function() {
        var items = [];
        angular.forEach($scope.line_items, function(line_item) {
          if (line_item.subtract_quantity > 0) {
            items.push({
              name: line_item.name,
              line_item_id: line_item.id,
              quantity: line_item.subtract_quantity
            });
          }
        });
        return items;
      };

      $scope.confirm_subtractables = function(){
        if($scope.can_subtract()){
          prepare_for_show();
          $scope.subtract_modal.show = true;
        }else{
          $rootScope.alert("请先选择要退菜品")
        }
      }

      function prepare_for_show(){
        var items = $scope.subtractables();
        var l = items.length;
        $scope.subtractables_l = items.slice(0, l/2)
        $scope.subtractables_r = items.slice(l/2)
      }

      $scope.can_subtract = function(){
        return $scope.subtractables().length > 0;
      }


      function init_subtract_modal(reasons){
        $scope.subtract_modal = {
          show: false,
          reasons: reasons,
          reason: '',
          choose_reason: function(reason){
            this.reason = reason;
          },
          can_submit: function(){
            return !$rootScope.is_submiting && $scope.can_subtract();
          },
          submit: function(){
            if(!$rootScope.is_submiting){
              $rootScope.is_submiting = true
              var subtractables = $scope.subtractables();
              angular.forEach(subtractables, function(subtractable){
                subtractable.reason = $scope.subtract_modal.reason
              })
              BaseOrderService.subtract($scope.order.type_str, $scope.branch_id, $scope.order.id, subtractables, function() {
                $rootScope.clear_authorizer()
                $rootScope.is_submiting = false
                $rootScope.alert("退菜成功");
                $scope.$emit("event:subtract_itemable:success")
              });
            }
          },
          cancel: function(){
            this.show = false;
          }
        }
      }

      ShopService.get(function(shop){
        init_subtract_modal(shop.subtract_reasons)
      })

    }]);
