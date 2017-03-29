WebposModules.add_controller('branch_fast_food')
angular.module('webpos.controllers.branch_fast_food', []).
  controller('branchFastFoodController',
    ['$rootScope','$scope','$timeout','$location','$routeParams','BranchService','FastfoodCartService','BaseOrderService', 'CartItemableAction', 'SetFastfoodExtendedForm',
    function($rootScope, $scope, $timeout,$location, $routeParams, BranchService, FastfoodCartService, BaseOrderService, CartItemableAction, SetFastfoodExtendedForm){

      $scope.branch_id = $routeParams.branch_id
      CartItemableAction.init($scope.branch_id, "fastfood", function(cart){ $scope.cart = cart })
      $scope.change_active_line_item = CartItemableAction.change_active_line_item;
      $scope.add_itemable            = CartItemableAction.add_itemable;
      $scope.remove_itemable         = CartItemableAction.remove_itemable;
      $scope.clear                   = CartItemableAction.clear;
      $scope.clearWithoutConfirm     = CartItemableAction.clearWithoutConfirm;

      $scope.change_note             = CartItemableAction.change_note;
      $scope.batch_change_note       = CartItemableAction.batch_change_note;
      $scope.change_gift             = CartItemableAction.change_gift;
      $scope.change_weight           = CartItemableAction.change_weight;
      $scope.edit_line_item          = CartItemableAction.edit_line_item;

      var clear_choose_itemable_listener = $scope.$on("event:choose_itemable", function(event, itemable){
        CartItemableAction.add_itemable_separate(itemable)
      });

      SetFastfoodExtendedForm({
        scope: $scope,
        model_name: 'cart',
        reload: true
      });

      $scope.$on("$destroy", function(){
        clear_choose_itemable_listener();
        CartItemableAction.dispose()
      })

      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
        var modify_order_id = $location.search().modify_order_id
        if(modify_order_id){
          BaseOrderService.cancel("fastfood", $scope.branch_id, modify_order_id, "快餐修改", function(order){
            $scope.clear()
            angular.forEach(order.line_items, function(line_item){
              for(var i=0;i<line_item.quantity;i++){
                $scope.add_itemable(line_item)
              }
            })
          })
        }
      })

      $scope.cart = null
      $scope.note = ""

      $scope.order_type = "fastfood"
      $scope.order_id = null
      $scope.order = null

      $scope.can_submit = function(){
        return !$rootScope.is_submiting && $scope.cart && $scope.cart.line_items.length > 0
      }

      $scope.submit = function(){
        if($scope.can_submit()){
          $rootScope.is_submiting = true
          FastfoodCartService.place_cart($scope.branch_id, {
            note: $scope.note,
            food_number: $scope.food_number_modal.food_number
          }, function(resp){
            $rootScope.is_submiting = false
            $scope.clearWithoutConfirm()
            $scope.note = ""
            $scope.food_number_modal.reset();
            $scope.order_id = resp.order_id
            $rootScope.go("/branches/"+$scope.branch_id+"/orders/"+ $scope.order_id+"/settle/"+resp.type_str)
          })
        }
      }

      $scope.food_number_modal = {
        show: false,
        food_number: null,
        can_confirm: function(){
          return this.food_number != null && this.food_number!="";
        },
        confirm: function(){
          if(this.can_confirm()){
            this.show = false;
          }
        },
        cancel: function(){
          this.show = false;
          this.food_number = null;
        },
        reset: function(){
          this.show = false;
          this.food_number = null;
        }
      }



    }])
