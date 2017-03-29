"use strict"
Ddt.module("ddt_app.controllers.product", [])
  .controller('deliveryProductsController', ['$rootScope', '$scope', '$routeParams', 'BaseProductsController', 'BranchService',
  function($rootScope, $scope, $routeParams, BaseProductsController, BranchService){

    $scope.cart_type = 'delivery'
    $scope.route_cart_type = 'delivery'
    $scope.snap = true;
    BaseProductsController.action($scope, function(){
      $scope.init_cart(true)

      // $scope.branch 这时不一定加载完成。
      // 如果之前获取过，这里会用缓存。
      BranchService.get({id: $routeParams.branch_id}, function(branch){
        $scope.branch = branch;
        $rootScope.title = branch.name
        if($scope.branch.receive_delivery_order_within_days == 0 && !$scope.branch.delivery_today_can_order){
          $rootScope.alert("外送时间已过, 请明天再来");
          $rootScope.back();
        }
      });

    });

    $scope.reasons = function(){
      var msgs = [];
      if(!($scope.branch && $scope.branch.is_in_service)){ msgs.push("该商家还未营业") }
      if(!($scope.cart && $scope.cart.item_count>0))          { msgs.push("您还未选择产品")}
      if(!($scope.cart.total >= parseFloat($scope.branch.support_delivery_if_amount_gt))){
        msgs.push("最低 " + $scope.currency + $scope.branch.support_delivery_if_amount_gt +" 起送");
      }
      return msgs;
    }

    $scope.can_submit = function(){
      return $scope.branch && $scope.branch.is_in_service && $scope.cart && $scope.cart.item_count > 0 && $scope.cart.total >= parseFloat($scope.branch.support_delivery_if_amount_gt);
    }

}]).controller('eatInHallProductsController', ['$rootScope', '$scope', 'BaseProductsController', 'SnapCartService', 'EatInHallCartService', 'TableService', 'UserService',
  function($rootScope, $scope, BaseProductsController, SnapCartService, EatInHallCartService, TableService, UserService){
    $scope.cart_type = 'eat_in_hall'
    $scope.snap = true;
    $scope.route_cart_type = 'eat_in_hall'

    UserService.get(function(user){
      $scope.user = user
    })

    BaseProductsController.action($scope, function(){
      $scope.init_cart(false, function(){
        SnapCartService.set_cart($scope.cart_type, $scope.branch_id, $scope.cart)
        // 如果不是wifiuser且没有桌台号，就跳转；wifiuser新登录没有桌台号是正常情况
        if(!$scope.user.wifi_code && !$scope.cart.table_id){
          $rootScope.go("/branches/" + $scope.branch_id)
        }
      })
    })

    $scope.submit = function(){
      if($scope.can_submit()){
        SnapCartService.update_cart($scope.cart_type, $scope.branch_id, function(cart){
          SnapCartService.set_cart($scope.cart_type, $scope.branch_id, null)
          if(!$scope.user.wifi_code){
            $rootScope.go("/branches/" + $scope.branch_id + "/tables/" + $scope.cart.table_id + "/merge_order_itemables")
          }
          else{
            $rootScope.go("/branches/" + $scope.branch_id + "/selecttable")
          }
        })
      }
    }

    $scope.reasons = function(){
      var msgs = [];
      if(!($scope.cart && $scope.cart.item_count > 0)){ msgs.push("您还未选择产品")}
      if(!$scope.select_table){msgs.push("请选择您的就餐桌台号")}
      return msgs;
    }

    $scope.can_submit = function(){
      return true
    }
}]).controller('tableSelectController', ['$rootScope', '$scope', '$routeParams', 'TableService', 'UserService',
  function($rootScope, $scope, $routeParams, TableService, UserService){
    $scope.cart_type = 'eat_in_hall'
    $scope.snap = true;
    $scope.route_cart_type = 'eat_in_hall'
    $scope.branch_id = $routeParams.branch_id

    $scope.active_guest_num = 0;
    $scope.active_selecet_table = 0;
    $scope.guest_nums = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]

    TableService.get_all($scope.branch_id, function(tables){
      $scope.tables = tables;
    })

    $scope.change_guest_num = function(guest_num){
      $scope.active_guest_num = guest_num;
    }

    $scope.change_select_table = function(table){
      $scope.active_select_table = table;
    }

    UserService.get(function(user){
      $scope.user = user
    })

    $scope.submit = function(){
      if($scope.active_select_table && $scope.active_guest_num){
        document.cookie = "guest_num=" + $scope.active_guest_num + ";"
        $rootScope.go("/branches/" + $scope.branch_id + "/tables/" + $scope.active_select_table.id + "/merge_order_itemables")
      }
      else{
        $rootScope.alert('请选择桌台和人数');
      }
    }

}]).controller('fastfoodProductsController', ['$rootScope', '$scope', 'BaseProductsController',
  function($rootScope, $scope, BaseProductsController){
    $scope.cart_type = 'fastfood'
    $scope.route_cart_type = 'fastfood'
    $scope.snap = true;
    BaseProductsController.action($scope, function(){
      $scope.init_cart(true)
    })

    $scope.reasons = function(){
      var msgs = [];
      if(!($scope.cart && $scope.cart.item_count > 0)){ msgs.push("您还未选择产品")}
      if(!($scope.branch && $scope.branch.is_in_service)){ msgs.push("该商家还未营业") }
      return msgs;
    }

    $scope.can_submit = function(){
      return $scope.branch && $scope.branch.is_in_service && $scope.cart && $scope.cart.item_count > 0 && $scope.cart.total > 0
    }

}]).controller('queuePreOrderingProductsController', ['$rootScope', '$scope', 'BaseProductsController','EatInHallCartService','SnapCartService','GuestQueueService',
  function($rootScope, $scope, BaseProductsController,EatInHallCartService,SnapCartService, GuestQueueService){
    $scope.cart_type = 'eat_in_hall'
    $scope.route_cart_type = 'queue_pre_ordering'
    $scope.snap = true;
    BaseProductsController.action($scope, function(){
      $scope.init_cart(true)
      $scope.submit = function(){
        if($scope.can_submit()){
          SnapCartService.update_cart($scope.cart_type, $scope.branch_id, function(cart){
            $rootScope.go_page('queue', '/branches/' + $scope.branch_id + "/guest_queue")
          })
        }else{
          $rootScope.$emit("events:receive_errors", $scope.reasons());
        }
      }
    })

    $scope.reasons = function(){
      var msgs = [];
      if(!($scope.cart && $scope.cart.item_count > 0)){ msgs.push("您还未选择产品")}
      return msgs;
    }

    $scope.can_submit = function(){
      return $scope.cart && $scope.cart.total > 0
    }

}]).controller('reservationProductsController', ['$rootScope', '$scope', 'BaseProductsController',
  function($rootScope, $scope, BaseProductsController){
    $scope.cart_type = 'reservation'
    $scope.route_cart_type = 'reservation'
    $scope.snap = true;
    BaseProductsController.action($scope, function(){
      $scope.init_cart(true)
      if(!$scope.cart.reservation_date_str || !$scope.cart.reservation_time_point_str){
        $rootScope.go("/branches/" + $scope.branch_id + '/reservation_time_points')
      }
    })

    $scope.reasons = function(){
      var msgs = [];
      if(!($scope.cart && $scope.cart.total >= $scope.cart.table_zone.min_reservation_price)){
        msgs.push("不得低于起定价： " + $scope.currency + $scope.cart.table_zone.min_reservation_price)
      }
      return msgs;
    }

    $scope.can_submit = function(){
      return $scope.cart && $scope.cart.total >= $scope.cart.table_zone.min_reservation_price
    }

}]).factory('ProductUtil', [function(){
  function action($scope, callback){
    $scope.filter_products = function(products){
      if(!products){return []}
      if(!$scope.cart || !$scope.cart.table){return products}
      var ban_product_ids = $scope.cart.table.ban_product_ids;
      if(!ban_product_ids || ban_product_ids.length == 0){ return products}
      return products.filter(function(product){
        return ban_product_ids.indexOf(product.id) == -1;
      })
    }
    if(callback){
      callback();
    }
  }
  return {action: action}
}]).factory('BaseProductsController', ['$rootScope', '$location', '$routeParams', '$timeout', 'ProductUtil', 'ProductService', 'BranchService',
  'CategoryService', 'CartAction', 'SnapCartService','BaseCartService', 'UrlHelperService', 'CategoryCache',
    function ($rootScope, $location, $routeParams, $timeout, ProductUtil, ProductService, BranchService,
      CategoryService, CartAction, SnapCartService, BaseCartService, UrlHelperService, CategoryCache) {
      function action($scope, callback){
        touchScroll('#category-list-div');
        touchScroll('#product-list-div');

        $scope.notice_switch = true;
        $scope.branch_id = $routeParams.branch_id
        $scope.branch = null
        $scope.categories = []
        $scope.active_category = null
        $scope.active_sub_category = null
        $scope.all_variants = []
        $scope.cart = null
        ProductUtil.action($scope)
        CartAction.action($scope)


        BranchService.get({id: $routeParams.branch_id}, function(branch){
          $scope.branch = branch;
        });

        CategoryService.query($routeParams.branch_id, $scope.cart_type, function(categories){
          $scope.categories = categories
          fetch_active_category_from_url_helper()
          if(!$scope.active_category) {
            $scope.active_category = $scope.categories[0];
            if($scope.active_category.categories && $scope.active_category.categories.length > 0){
              $scope.active_sub_category = $scope.active_category.categories[0];
            }
            if($scope.default_products){
              set_products($scope.default_products)
            }else{
              $scope.query_products();
            }
          }else{
            $scope.query_products();
          }
        })

        function fetch_active_category_from_url_helper(){
          var cached_category = $scope.get_category_cache();
          if(cached_category.category_id){
            $scope.categories.some(function(category){
              if(category.id == cached_category.category_id){
                $scope.active_category = category;
                if(cached_category.sub_category_id && $scope.active_category.categories){
                  $scope.active_category.categories.some(function(sub){
                    if(sub.id == cached_category.sub_category_id){
                      $scope.active_sub_category = sub;
                      return true;
                    }
                  });
                }else if($scope.active_category.categories && $scope.active_category.categories.length > 0 ){
                  $scope.active_sub_category = $scope.active_category.categories[0];
                }
                return true;
              }
            });
          }
        }

        $scope.init_cart = function(is_snap, cb){
          if(is_snap){
            SnapCartService.get($scope.cart_type, $scope.branch_id, function(cart){
              $scope.cart = cart;
              $timeout(function(){
                $rootScope.$broadcast('cart:snap:change', cart);
              }, 0)
              if(cb){cb()}
            })
          }else{
            BaseCartService.get($scope.cart_type, $scope.branch_id, function(cart){
              $scope.cart = cart;
              $rootScope.$broadcast('cart:change', cart);
              if(cb){cb()}
            })
          }
        }

        $scope.query_products = function(){
          var current_category = $scope.active_sub_category || $scope.active_category;
          if(current_category.products){
            $scope.products = $scope.filter_products(current_category.products)
            $scope.check_default_sub_category()
          }else{
            ProductService.query({
              branch_id: $scope.branch_id,
              order_type: $scope.cart_type,
              category_id: current_category.id,
              date: ($scope.cart ? $scope.cart.reservation_date : null)
            }, function(products){
              set_products(products)
            })
          }
        }

        function set_products(products){
          var products = $scope.filter_products(products);
          var current_category = $scope.active_sub_category || $scope.active_category
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
          $scope.check_default_sub_category()
        }

  

        $scope.check_default_sub_category = function(){
          if($scope.products.length == 0 && $scope.active_sub_category == null && $scope.active_category.categories.length > 0){
            $scope.active_sub_category = $scope.active_category.categories[0]
            $scope.query_products()
          }
        }

        $scope.active_variant = function(product, variant){
          product.active_variant = variant
        }

        $scope.toggle_notice_switch = function(){
          $scope.notice_switch = !$scope.notice_switch;
        }

        $scope.change_active_category = function(category){
          $scope.active_category.scroll_top  = $('#product-list-div').scrollTop();
          $scope.active_category = category;
          $scope.active_sub_category = null;
          if($scope.active_category.categories && $scope.active_category.categories.length > 0){
            $scope.active_sub_category = $scope.active_category.categories[0]
          }
          $scope.query_products()
          setTimeout(function(){
            $('#product-list-div').scrollTop($scope.active_category.scroll_top);
          })
        }

        $scope.change_sub_categroy = function(sub_category) {
          $scope.active_sub_category = sub_category;
          $scope.query_products()
        }

        $scope.is_show_default_sub_category = function(category){
          return category && category.categories.length > 0 && category.products && category.products.length > 0
        }

        $scope.update_variant_quantity = function(cart){
          angular.forEach($scope.all_variants, function(variant){
            variant.quantity = 0
            variant.line_items = [];
            angular.forEach(cart.line_items, function(line_item){
              if(cart.branch_check_stock && line_item.stock_quantity < line_item.quantity){
                // 库存不足购物车
                line_item.quantity = line_item.stock_quantity
              }
              if(variant.itemable_type == line_item.itemable_type && variant.itemable_id == line_item.itemable_id){
                variant.quantity += line_item.quantity;
                if(line_item.quantity > 0){
                  variant.line_items.push(line_item)
                }
              }
            })
          })
        }

        $scope.update_category_quantity = function(cart){
          angular.forEach($scope.categories, function(category){
            category.quantity = 0
            angular.forEach(cart.line_items, function(line_item){
              if(cart.branch_check_stock && line_item.stock_quantity < line_item.quantity){
                // 库存不足购物车
                line_item.quantity = line_item.stock_quantity
              }
              var same_ids = line_item.category_ids.filter(function(n){ return category.all_ids.indexOf(n) != -1})
              if(same_ids.length > 0){
                category.quantity += line_item.quantity || 0
              }
            })
          })
        }
        function cartChanged(e, cart){
          $scope.cart = cart;
          $scope.update_variant_quantity(cart)
          $scope.update_category_quantity(cart)
          if($scope.active_category){
            $scope.query_products()
          }
        }

        $rootScope.$on("cart:snap:change", cartChanged)
        $rootScope.$on("cart:change", cartChanged)


        $scope.submit = function(){
          if($scope.can_submit()){
            SnapCartService.update_cart($scope.cart_type, $scope.branch_id, function(cart){
              $rootScope.go("/branches/" + $scope.branch_id + "/cart/" + $scope.cart_type, false)
            })
          }else{
            $rootScope.$emit("events:receive_errors", $scope.reasons());
          }
        }

        $scope.go_show_product_with_update = function(product){
          $scope.cache_category()
          SnapCartService.update_cart($scope.cart_type, $scope.branch_id, function(cart){
            $rootScope.go_show_product(product, $scope.route_cart_type)
          })
        }

        $scope.go_search_product_with_update = function(){
          $scope.cache_category()
          SnapCartService.update_cart($scope.cart_type, $scope.branch_id, function(cart){
            $rootScope.go_search_product($scope.branch_id, $scope.route_cart_type)
          })
        }

        $scope.go_combos = function(){
          $scope.cache_category()
          SnapCartService.update_cart($scope.cart_type, $scope.branch_id, function(cart){
            $rootScope.go("/branches/"+$scope.branch_id+"/combos?order_type="+$scope.route_cart_type)
          })
        }

        $scope.cache_category = function(){
          CategoryCache.put("category_id", $scope.active_category.id)
          if($scope.active_sub_category){
            CategoryCache.put("sub_category_id", $scope.active_sub_category.id)
          }
        }

        $scope.get_category_cache = function(){
          return {
            category_id:      CategoryCache.get("category_id"),
            sub_category_id:  CategoryCache.get("sub_category_id"),
          }
        }

        $scope.add_itemable_with_note = function(variant){
          if(variant.show_note_in_weixin){
            $rootScope.item_note_modal.open(variant.item_notes, function(note){
              variant.note = note
              $scope.add_itemable(variant)
            })
          }else{
            $scope.add_itemable(variant)
          }
        }

        if(callback){callback();}
      }

    return {
      action: action
    };
}]).controller('productController', [
  '$rootScope', '$routeParams', '$location', '$scope', 'ProductService', 'BaseCartService', 'CartAction',
  function ($rootScope, $routeParams, $location, $scope, ProductService, BaseCartService, CartAction) {
    $rootScope.title = '详情';
    $scope.branch_id = $routeParams.branch_id;
    $scope.product_id = $routeParams.product_id;
    $scope.product = null;
    $scope.master_variant = null;
    $scope.cart_type = $location.search().cart_type || 'delivery'
    $scope.route_cart_type = $scope.cart_type
    if($scope.cart_type == "queue_pre_ordering"){
      $scope.cart_type = "eat_in_hall"
      $scope.route_cart_type = "queue_pre_ordering"
    }
    else{
      $scope.route_cart_type = $scope.cart_type
    }

    CartAction.action($scope)

    ProductService.get($scope.branch_id, $scope.product_id, function(product){
      $scope.product = product;
      $scope.product.rect_images = [];
      angular.forEach(product.images, function(image){
        $scope.product.rect_images.push({
          img: image.rect_large_url
        });
      });
      $scope.master_variant = $scope.product.variants[0]
      BaseCartService.get($scope.cart_type, $scope.branch_id, function(cart){
        $scope.cart = cart
        $scope.update_variant_quantity()
      })
    })



    $scope.update_variant_quantity = function(){
      angular.forEach($scope.product.variants, function(variant){
        variant.quantity = 0
        angular.forEach($scope.cart.line_items, function(line_item){
          if(line_item.itemable_type == "Ddt::Variant" && line_item.itemable_id == variant.id){
            variant.quantity += line_item.quantity
          }
        })
      })
    }

    $rootScope.$on('cart:change', function(e, cart){
      $scope.cart = cart
      $scope.update_variant_quantity()
    })

    $scope.add_itemable_with_note = function(variant){
      if(variant.show_note_in_weixin){
        $rootScope.item_note_modal.open(variant.item_notes, function(note){
          variant.note = note
          $scope.add_itemable(variant, false)
        })
      }else{
        $scope.add_itemable(variant, false)
      }
    }


}]).controller('searchProductsController', [
  '$rootScope', '$scope', '$routeParams', '$location', 'ProductUtil', 'ProductService', 'CartAction', 'BaseCartService',
  function ($rootScope, $scope, $routeParams, $location ,ProductUtil, ProductService, CartAction, BaseCartService) {
    $rootScope.title = '搜索'
    $scope.branch_id = $routeParams.branch_id
    $scope.cart_type = $location.search().cart_type
    $scope.route_cart_type = $scope.cart_type
    $scope.snap = false;
    if($scope.cart_type == "queue_pre_ordering"){
      $scope.cart_type = "eat_in_hall"
      $scope.route_cart_type = "queue_pre_ordering"
    }


    $scope.query_string = null
    $scope.products = []
    $scope.cart = null

    ProductUtil.action($scope)
    CartAction.action($scope)

    BaseCartService.get($scope.cart_type, $scope.branch_id, function(cart){
      $scope.cart = cart
    })

    $scope.search = function(){
      if($scope.query_string){
        ProductService.query({
          branch_id: $scope.branch_id,
          order_type: $scope.cart_type,
          name: $scope.query_string
        }, function(products){
          $scope.products = $scope.filter_products(products);
          init_active_variant()
          update_variant_quantity()
        })
      }
    }

    $scope.$watch('query_string', function(){
      $scope.search()
    })

    function init_active_variant(){
      angular.forEach($scope.products, function(product){
        if(product.variants.length == 1){
          product.active_variant = product.variants[0]
        }else{
          product.active_variant = product.variants[1]
        }
      })
    }

    function update_variant_quantity(){
      angular.forEach($scope.products, function(product){
        angular.forEach(product.variants, function(variant){
          variant.quantity = 0
          variant.line_items = [];
          angular.forEach($scope.cart.line_items, function(line_item){
            if(variant.itemable_type == line_item.itemable_type && variant.itemable_id == line_item.itemable_id){
              variant.quantity += line_item.quantity
              if(line_item.quantity > 0){
                variant.line_items.push(line_item)
              }
            }
          })
        })
      })
    }

    $scope.active_variant = function(product, variant){
      product.active_variant = variant
    }

    $rootScope.$on('cart:change', function(e, cart){
      $scope.cart = cart
      update_variant_quantity()
    })

    $scope.clear_query_string = function(){
      $scope.query_string = null
    }

    $scope.add_itemable_with_note = function(variant){
      if(variant.show_note_in_weixin){
        $rootScope.item_note_modal.open(variant.item_notes, function(note){
          variant.note = note
          $scope.add_itemable(variant, false)
        })
      }else{
        $scope.add_itemable(variant, false)
      }
    }

}])
