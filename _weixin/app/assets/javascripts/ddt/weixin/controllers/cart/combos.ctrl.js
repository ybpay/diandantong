Ddt.module("ddt_app.controllers.combos", [])
  .controller('combosController', [
  '$rootScope', '$scope', '$routeParams', '$location', 'ComboService','BranchService','BaseCartService','SnapCartService','AppendItemableService',
  function($rootScope, $scope, $routeParams, $location, ComboService, BranchService, BaseCartService, SnapCartService, AppendItemableService){
    $scope.append_combo = false;
    if ($location.path().indexOf("append_combo") != -1){
      $scope.append_combo = true;
      $scope.order_id = $routeParams.order_id;
      $scope.order_type = $routeParams.order_type;
      AppendItemableService.init()
    }else{
      $scope.order_type = $location.search().order_type
      $scope.route_order_type = $scope.order_type
      if($scope.order_type == "queue_pre_ordering"){
        $scope.order_type = "eat_in_hall"
        $scope.route_order_type = "queue_pre_ordering"
      }
    }
    $scope.branch_id = $routeParams.branch_id
    $scope.combos = []
    $scope.active_combo = null

    BranchService.get({id: $scope.branch_id}, function(branch){
      $scope.branch = branch
    })

    ComboService.query($scope.branch_id, $scope.order_type, function(combos){
      $scope.combos = combos
      $scope.active_combo = combos[0]
      angular.forEach($scope.combos, function(combo){
        reset_combo(combo)
      })
    })

    $scope.change_active_combo = function(combo){
      $scope.active_combo = combo
    }

    $scope.stock_of = function(variant){
      if(variant.quantity == undefined){
       return variant.stock_quantity;
      }
      return variant.stock_quantity - variant.quantity;
    }

    $scope.can_add = function(combo_item, variant){
      variant.quantity = variant.quantity || 0
      return combo_item.quantity < combo_item.select_count && variant.stock_quantity > variant.quantity
    }

    $scope.add_item = function(combo_item, variant){
      if($scope.can_add(combo_item, variant)){
        combo_item.quantity ++
        variant.quantity ++
      }
    }

    $scope.can_remove = function(combo_item, variant){
      return variant.quantity > 0
    }

    $scope.remove_item = function(combo_item, variant){
      if($scope.can_remove(combo_item, variant)){
        combo_item.quantity --
        variant.quantity --
      }
    }

    $scope.toggle_combo_item = function(combo_item){
      combo_item.show = !combo_item.show
    }

    $scope.can_submit = function(){
      var result = true
      if(!$scope.active_combo || $scope.active_combo.combo_items.length === 0){
        result = false
      }else{
        angular.forEach($scope.active_combo.combo_items, function(combo_item){
          if( combo_item.is_necessary && combo_item.quantity !== combo_item.select_count){ result = false }
        })
      }
     return result
    }

    $scope.errors = function(){
      var errors = [];
      if(!$scope.active_combo || $scope.active_combo.combo_items.length === 0){
        errors.push('商家套餐配置不完整');
      }else{
        angular.forEach($scope.active_combo.combo_items, function(combo_item){
          if( combo_item.is_necessary && combo_item.quantity !== combo_item.select_count){
            errors.push(combo_item.name +'为必选项, 最少选择'+combo_item.select_count+'份')
          }
        })
      }
      return errors;
    }

    $scope.submit = function(){
      if($scope.can_submit()){
        $rootScope.confirm($scope.active_combo.name, get_content(), function(){
          if($scope.append_combo){
            ComboService.add_combo_package($scope.branch_id, get_params(), function(combo_package){
              AppendItemableService.add_combo_package(combo_package)
              $rootScope.go('/branches/'+$scope.branch_id+'/orders/'+$scope.order_id+'/'+$scope.order_type+'/append_itemable')
            })
          }else{
            BaseCartService.add_combo_package($scope.order_type, $scope.branch_id, get_params(), function(cart){
              SnapCartService.set_cart($scope.order_type, $scope.branch_id, cart)
                $rootScope.go_products_list($scope.branch_id, $scope.route_order_type)
            })
          }
        })
      }else{
        $rootScope.alert($scope.errors().join(', '))
      }
    }

    function get_params(){
      var params = {
        combo_id: $scope.active_combo.id,
        items: []
      }
      if($scope.append_combo){
        params["name"] = "["+$scope.active_combo.name+"]" + get_content();
        params["price"] = $scope.active_combo.price
      }
      angular.forEach($scope.active_combo.combo_items, function(combo_item){
        angular.forEach(combo_item.variants, function(variant){
          if(variant.quantity > 0){
            params.items.push({
              combo_item_id: combo_item.id,
              variant_id: variant.id,
              quantity: variant.quantity
            })
          }
        })
      })
      return params
    }

    function get_content(){
      var content = ""
      angular.forEach($scope.active_combo.combo_items, function(combo_item){
        angular.forEach(combo_item.variants, function(variant){
          if(variant.quantity > 0){
            content = content + variant.name + "*" + variant.quantity + " "
          }
        })
      })
      return  content
    }

    function reset_combo(combo){
      angular.forEach(combo.combo_items, function(combo_item){
        combo_item.quantity = 0
        combo_item.show = false
        angular.forEach(combo_item.variants, function(variant){
          variant.quantity = 0
        })
        if(combo_item.select_count == 1 && combo_item.variants.length == 1){
          $scope.add_item(combo_item, combo_item.variants[0])
        }
      })
    }

  }
]);



