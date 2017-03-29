
Ddt.controller('cartController',
  ['$rootScope', '$scope', '$routeParams', 'UserService', 'BaseCartService', 'SnapCartService', 'CartAction',
  function($rootScope, $scope, $routeParams, UserService, BaseCartService, SnapCartService, CartAction){
    $rootScope.title = '已选菜品';
    $scope.can_refresh = false;
    $scope.branch_id = $routeParams.branch_id
    $scope.cart_type = $routeParams.cart_type;

    CartAction.action($scope)

    UserService.get(function(user){
      $scope.user = user;
    })

    $scope.$on('cart:change', function(event, cart){
      set_cart(cart)
    })

    $scope.refresh = function(){
      BaseCartService.get($scope.cart_type, $scope.branch_id, function(cart){
        set_cart(cart)
      })
    }
    $scope.refresh();

    function set_cart(cart){
      $scope.cart = cart;
      to_order_itemables_groups(cart)
    }

    function to_order_itemables_groups(cart){
      if(cart.line_items.length == 0){
        $scope.order_itemables_groups = []
      }else{

        var count = 0;
        angular.forEach(cart.line_items, function(line_item){count += line_item.quantity})
        $scope.order_itemables_groups = [{user_id: cart.user_id, user_name: cart.user_name, head_url: cart.head_url, itemables: cart.line_items, count: count}]
      }
    }

    $scope.toggle_group = function(group){
      group.hide = !group.hide;
    }

    $scope.can_action = function(group){
      return $scope.user && group.user_id == $scope.user.id
    }

    $scope.plus = function(group, itemable){
      $scope.add_itemable(itemable, false)
    }

    $scope.minus= function(group, itemable){
      $scope.remove_itemable(itemable, false)
    }

    $scope.can_submit = function(){
      return $scope.cart && $scope.cart.line_items.length > 0;
    }
    $scope.submit = function(){
      if($scope.can_submit()){
        SnapCartService.update_cart($routeParams.cart_type, $routeParams.branch_id, function(cart){
          $rootScope.go("/branches/" + $routeParams.branch_id + "/orders/" + $routeParams.cart_type + "/new", false)
        })
      }else{
        $rootScope.alert('购物车为空')
      }
    }

    $scope.back = function(){
      $rootScope.go_products_list($routeParams.branch_id, $routeParams.cart_type)
    }

  }])

.controller('tableCartController',
  ['$rootScope', '$scope', '$routeParams', 'EatInHallCartService', 'OrderItemableService', 'TableService', 'UserService','BaseCartService','SnapCartService',
  function($rootScope, $scope, $routeParams, EatInHallCartService, OrderItemableService, TableService, UserService, BaseCartService,SnapCartService){
    $rootScope.title = "已选菜品";
    $scope.branch_id = $routeParams.branch_id
    $scope.table_id = $routeParams.table_id;
    $scope.can_refresh = true;

    TableService.get($scope.branch_id, $scope.table_id, function(table){
      $scope.table = table;
      $rootScope.title = table.name_with_zone + '已选菜品';
    })

    UserService.get(function(user){
      $scope.user = user;
    })

    $scope.can_action = function(group){
      return $scope.user && group.user_id == $scope.user.id
    }

    $scope.back = function(){
      $rootScope.go_products_list($scope.branch_id, 'eat_in_hall')
    }

    $scope.can_submit = function(){
      var itemable_count = 0
      angular.forEach($scope.order_itemables_groups, function(group){
        itemable_count += group.itemables.length
      })
      return !$rootScope.is_submiting && itemable_count > 0
    }

    $scope.refresh = function(){
      OrderItemableService.query($scope.branch_id, $scope.table_id, function(group){
        $scope.order_itemables_groups = group;
        var variant_ids = []
        var repeat_variant_ids = []
        angular.forEach($scope.order_itemables_groups, function(group){
          angular.forEach(group.itemables, function(itemable){
            if(itemable.itemable_type == "Ddt::Variant"){
              if(variant_ids.indexOf(itemable.itemable_id) != -1){
                repeat_variant_ids.push(itemable.itemable_id)
              }else{
                variant_ids.push(itemable.itemable_id)
              }
            }
          })
        })
        angular.forEach($scope.order_itemables_groups, function(group){
          angular.forEach(group.itemables, function(itemable){
            if(itemable.itemable_type == "Ddt::Variant" && repeat_variant_ids.indexOf(itemable.itemable_id) != -1){
              itemable.is_repeat = true
            }
          })
        })
        to_cart(group)
      })
    }
    $scope.refresh();

    function to_cart(groups){
      var cart = {item_count: 0, total: 0}
      angular.forEach(groups, function(group){
        angular.forEach(group.itemables, function(itemable){
          cart.item_count += itemable.quantity
          cart.total += itemable.price * itemable.quantity
        })
      })
      $scope.cart = cart;
    }

    $scope.toggle_group = function(group){
      group.hide = !group.hide;
    }

    $scope.plus = function(group, itemable){
      if( (!$rootScope.is_submiting) && $scope.can_action(group)){
        $rootScope.is_submiting = true
        OrderItemableService.plus($scope.branch_id, $scope.table_id, itemable.id, function(new_itemable){
          var n = new_itemable.quantity - itemable.quantity
          if(new_itemable.quantity > 0){
            itemable.quantity = new_itemable.quantity
          }else{
            var index = group.itemables.indexOf(itemable);
            group.itemables.splice(index, 1);
          }
          group.count += n;
          $rootScope.is_submiting = false
          to_cart($scope.order_itemables_groups)
        })
      }
    }

    $scope.minus = function(group, itemable){
      if( (!$rootScope.is_submiting) && $scope.can_action(group)){
        $rootScope.is_submiting = true
        OrderItemableService.minus($scope.branch_id, $scope.table_id, itemable.id, function(new_itemable){
          var n = itemable.quantity - new_itemable.quantity;
          if(new_itemable.quantity > 0){
            itemable.quantity = new_itemable.quantity
          }else{
            var index = group.itemables.indexOf(itemable);
            group.itemables.splice(index, 1);
          }
          group.count -= n;
          $rootScope.is_submiting = false
          to_cart($scope.order_itemables_groups)
        })
      }
    }

    $scope.submit = function(){
      if($scope.can_submit()){
        $rootScope.is_submiting = true
        EatInHallCartService.set_order_itemables_from_table($scope.branch_id, $scope.table_id, function(cart){
          $rootScope.is_submiting = false
          if($scope.cart.item_count == cart.item_count){
            SnapCartService.set_cart('eat_in_hall', $scope.branch_id, cart)
            BaseCartService.set_cache_cart('eat_in_hall', $scope.branch_id, cart)
            $rootScope.go("/branches/" + $scope.branch_id + "/orders/eat_in_hall/new")
          }else{
            $rootScope.alert('购物车已发生变更，请刷新确认')
          }
        })
      }else{
        $rootScope.alert('购物车为空!')
      }
    }


  }])
