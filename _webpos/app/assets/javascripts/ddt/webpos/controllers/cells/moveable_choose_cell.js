WebposModules.add_cell('moveable_choose');
angular.module('webpos.cells.moveable_choose', []).
  controller('moveableChooseCell',
    ['$rootScope', '$scope', '$routeParams', 'BaseOrderService', "EatInHallOrderService", 'ShopService', 'TableService',
    function($rootScope, $scope, $routeParams, BaseOrderService, EatInHallOrderService, ShopService, TableService) {

      $scope.branch_id = $routeParams.branch_id;
      $scope.order = null;
      $scope.active_line_item = null;

      var clear_move_itemable_listener = $scope.$on("event:move_itemable:order", function(event, order) {
        $scope.order = order;
        BaseOrderService.active_line_items($scope.order.type_str, $scope.branch_id, $scope.order.id, function(active_line_items) {
          $scope.line_items = active_line_items;
          angular.forEach($scope.line_items, function(line_item){ line_item.move_quantity = 0 })
        });
      });
      $scope.$on("$destroy", function(){
        clear_move_itemable_listener()
      })

      $scope.change_active_line_item = function(line_item) {
        $scope.active_line_item = line_item;
      };

      $scope.can_plus = function(line_item) {
        return line_item && line_item.move_quantity > 0;
      };

      $scope.can_minus = function(line_item) {
        return line_item && line_item.active_quantity > line_item.move_quantity;
      }

      $scope.add = function(line_item) {
        if ($scope.can_plus(line_item)) {
          line_item.move_quantity -- ;
        }
      };

      $scope.remove = function(line_item) {
        if ($scope.can_minus(line_item)) {
          line_item.move_quantity++;
        }
      };

      $scope.moveables = function() {
        var items = [];
        angular.forEach($scope.line_items, function(line_item) {
          if (line_item.move_quantity > 0) {
            items.push({
              name: line_item.name,
              line_item_id: line_item.id,
              quantity: line_item.move_quantity
            });
          }
        });
        return items;
      };

      $scope.confirm_moveables = function(){
        if($scope.can_move()){
          prepare_for_show();
          $scope.move_modal.open()
        }else{
          $rootScope.alert("请先选择要退菜品")
        }
      }

      function prepare_for_show(){
        var items = $scope.moveables();
        var l = items.length;
        $scope.moveables_l = items.slice(0, l/2)
        $scope.moveables_r = items.slice(l/2)
      }

      $scope.can_move = function(){
        return $scope.moveables().length > 0;
      }


      $scope.move_modal = {
        show: false,
        tables: [],
        table: undefined,
        open: function(){
          this.show = true
          TableService.query($scope.branch_id, { "q[workflow_state_eq]": "ordered", "q[id_not_eq]": $scope.order.table_id}, function(tables){
            $scope.move_modal.tables = tables
          })
        },
        choose_table: function(table){
          this.table = table;
        },
        can_submit: function(){
          return !$rootScope.is_submiting && $scope.can_move() && this.table;
        },
        submit: function(){
          if(!$rootScope.is_submiting){
            $rootScope.is_submiting = true
            var moveables = $scope.moveables();
            EatInHallOrderService.move_itemable($scope.branch_id, $scope.order.id, moveables, this.table.id, function() {
              $rootScope.is_submiting = false
              $rootScope.alert("转菜成功");
              $scope.$emit("event:move_itemable:success")
            });
          }
        },
        cancel: function(){
          this.show = false;
        }
      }

    }]);
