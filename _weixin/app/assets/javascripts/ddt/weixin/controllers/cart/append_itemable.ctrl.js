Ddt.controller('orderAppendItemableController', [
    '$rootScope', '$scope', '$routeParams', 'BranchService', 'BaseOrderService', 'ProductService', 'CategoryService','AppendItemableService',
    function($rootScope, $scope, $routeParams, BranchService, BaseOrderService, ProductService, CategoryService, AppendItemableService){
      touchScroll('#category-list-div');
      touchScroll('#product-list-div');

      $rootScope.title = '加菜';
      $scope.branch_id = $routeParams.branch_id
      $scope.order_type = $routeParams.order_type
      $scope.order_id = $routeParams.order_id
      $scope.show_content = false;

      $scope.branch = null
      $scope.categories = []
      $scope.active_category = null
      $scope.active_sub_category = null
      $scope.all_variants = []
      $scope.cart = AppendItemableService.get_cart();

      BranchService.get({id: $scope.branch_id}, function (branch) {
        $scope.branch = branch;
      });

      BaseOrderService.get($scope.order_type, $scope.branch_id, $scope.order_id, function (order) {
        $scope.order = order;
        AppendItemableService.init(order)
      })

      CategoryService.query($scope.branch_id, $scope.order_type, function(categories){
        $scope.categories = categories
        $scope.active_category = $scope.categories[0];
        if($scope.active_category && $scope.active_category.categories && $scope.active_category.categories.length > 0){
          $scope.active_sub_category = $scope.active_category.categories[0];
        }
        if($scope.active_category){
          $scope.query_products()
        }
      })

      $scope.query_products = function(){
        var current_category = $scope.active_sub_category || $scope.active_category
        if(current_category.products){
          $scope.products = current_category.products
        }else{
          ProductService.query({
            branch_id: $scope.branch_id,
            order_type: $scope.order_type,
            category_id: current_category.id
          }, function(products){
            current_category.products = products
            angular.forEach(products, function(product){
              if(product.variants.length == 1){
                product.active_variant = product.variants[0]
              }else{
                product.active_variant = product.variants[1]
              }
              angular.forEach(product.variants, function(variant){
                $scope.all_variants.push(variant)
              })
            })
            $scope.products = products
            if($scope.cart){
              $scope.update_variant_quantity($scope.cart)
              $scope.update_category_quantity($scope.cart)
            }
            // console.log(products)
          })
        }
      }

      $scope.active_variant = function(product, variant){
        product.active_variant = variant
      }

      $scope.change_active_category = function(category){
        $scope.active_category = category;
        $scope.active_sub_category = null;
        if($scope.active_category.categories && $scope.active_category.categories.length > 0){
          $scope.active_sub_category = $scope.active_category.categories[0]
        }
        $scope.query_products()
      }

      $scope.change_sub_categroy = function(sub_category) {
        $scope.active_sub_category = sub_category;
        $scope.query_products()
      }

      $scope.update_variant_quantity = function(cart){
        angular.forEach($scope.all_variants, function(variant){
          variant.quantity = 0
          variant.line_items = []
          angular.forEach(cart.line_items, function(line_item){
            if(variant.itemable_type == line_item.itemable_type && variant.itemable_id == line_item.itemable_id){
              variant.quantity += line_item.quantity
              if(line_item.quantity > 0){
                variant.line_items.push(line_item);
              }
            }
          });
        });
      }

      $scope.update_category_quantity = function(cart){
        angular.forEach($scope.categories, function(category){
          category.quantity = 0
          angular.forEach(cart.line_items, function(line_item){
            if(line_item.itemable_type == 'Ddt::Variant'){
              var same_ids = line_item.category_ids.filter(function(n){ return category.all_ids.indexOf(n) != -1})
              if(same_ids.length > 0){
                category.quantity += line_item.quantity || 0
              }
            }
          })
        })
      }

      $scope.can_submit = function(){
        return $scope.cart && $scope.cart.item_count > 0 && ($scope.cart.total > 0 || ($scope.branch && $scope.branch.can_place_when_zero))
      }

      $scope.submit = function(){
        if($scope.can_submit()){
          $rootScope.go('/branches/'+$scope.branch_id+'/orders/'+$scope.order_id+'/'+$scope.order_type+'/append_itemable_confirm')
        }
      }

      // cart action
      $scope.add_itemable = function(itemable){
        if($scope.need_check_stock(itemable)){
          if(typeof(itemable.quantity) == 'undefined' && itemable.stock_quantity - 1 <=0)return;
          if(itemable.stock_quantity - itemable.quantity <= 0) return;
        }
        if(itemable.show_note_in_weixin){
          $rootScope.item_note_modal.open(itemable.item_notes, function(note){
            AppendItemableService.append_itemable(itemable, note, function(cart){
              $scope.cart = cart;
              cart_change()
            })
          })
        }else{
          AppendItemableService.append_itemable(itemable, itemable.note, function(cart){
            $scope.cart = cart;
            cart_change()
          })
        }
      }

      $scope.remove_itemable = function(itemable){
        AppendItemableService.remove_itemable(itemable, itemable.note, function(cart){
          $scope.cart = cart;
          cart_change()
        })
      }

      function cart_change(){
        $scope.update_variant_quantity($scope.cart)
        $scope.update_category_quantity($scope.cart)
        // console.log($scope.cart)
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

      // 套餐不检查库存
      $scope.need_check_stock = function(itemable){
        return ($scope.check_stock || ($scope.branch && $scope.branch.check_stock)) && itemable.itemable_type == "Ddt::Variant"
      }

      $scope.go_append_combo_package = function(){
        $rootScope.go('/branches/'+$scope.branch_id+'/orders/'+$scope.order_id+'/'+$scope.order_type+'/append_combo')
      }

      $scope.toggle_content = function(){
        $scope.show_content = !$scope.show_content;
      }

}])
