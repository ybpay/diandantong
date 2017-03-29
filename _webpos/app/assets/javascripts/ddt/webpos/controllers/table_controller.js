WebposModules.add_controller('table')
angular.module('webpos.controllers.table', []).
  controller('tableCartController',
    ['$rootScope','$scope', '$routeParams', '$timeout','TableZoneService', 'TableService','BranchService','TableCartService','CartItemableAction',
    function($rootScope, $scope, $routeParams, $timeout, TableZoneService, TableService, BranchService, TableCartService, CartItemableAction){

      $scope.table_id = $routeParams.table_id
      TableCartService.set_table_id($scope.table_id)
      $scope.cart = null
      $scope.branch_id = $routeParams.branch_id
      CartItemableAction.init($scope.branch_id, "table", function(cart){ $scope.cart = cart })
      $scope.change_active_line_item = CartItemableAction.change_active_line_item;
      $scope.add_itemable            = CartItemableAction.add_itemable;
      $scope.remove_itemable         = CartItemableAction.remove_itemable;
      $scope.clear                   = CartItemableAction.clear;
      $scope.change_note             = CartItemableAction.change_note;
      $scope.batch_change_note       = CartItemableAction.batch_change_note;
      $scope.change_gift             = CartItemableAction.change_gift;
      $scope.change_weight           = CartItemableAction.change_weight;
      $scope.edit_line_item          = CartItemableAction.edit_line_item;

      var clear_choose_itemable_listener = $scope.$on("event:choose_itemable", function(event, itemable){
        CartItemableAction.add_itemable_separate(itemable)
      })


      function store_cart(){
        TableCartService.set_cart($scope.cart)
      }

      function restore_cart(){
        TableCartService.get($scope.branch_id, function(cart){
          $scope.cart = cart;
        })
      }
      restore_cart();

      $scope.$on("$destroy", function(){
        store_cart();
        clear_choose_itemable_listener();
        CartItemableAction.dispose()
      })

      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
        $scope.table = null
        TableService.get($scope.branch_id, $scope.table_id, function(table){
          $scope.table = table
          // init ban product ids
          TableZoneService.get_ban_product_ids($scope.branch_id, $scope.table.table_zone_id, function(ban_product_ids){
            $scope.ban_product_ids = ban_product_ids;
          })

          if('opened' != $scope.table.workflow_state){
            $rootScope.go_branch($scope.branch)
            return;
          }
        })
      })

      $scope.place_cart = function(){
        if(!$rootScope.is_submiting){
          $rootScope.is_submiting = true
          TableCartService.place_cart($scope.branch_id, $scope.table_id,
            {
              is_local_printed: $rootScope.local_printer_configed(),
              bill_type: $rootScope.order_bill_type(),
              note: $scope.note
            }, function(result){
            $rootScope.is_submiting = false
            $rootScope.go_branch($scope.branch)
            if($rootScope.local_printer_configed()){
              var bill = result.bill;
              $rootScope.local_print_order_bill(bill, false)
              $rootScope.alert('落单成功');
            }else if($scope.branch.webpos_autoprinter_configed){
              $rootScope.alert('落单成功');
            }else{
              $rootScope.confirm("落单成功，您要打印该订单？", function(){
                var order = result;
                $rootScope.wire_print_order_bill(order)
              })
            }
          })
        }
      }
    }])
