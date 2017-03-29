WebposModules.add_controller('estimate')
angular.module('webpos.controllers.estimate', []).
  controller('EstimateController', ['$rootScope', '$scope', 'BranchService', 'Box', '$state', "$stateParams", "EstimateClear", "ProductService", "CategoryService", "LocalStorageCache", "$filter",
    function($rootScope, $scope, BranchService, Box, $state, $stateParams, EstimateClear, ProductService, CategoryService, LocalStorageCache, $filter){
      // -----------estimate_Clear
      $scope.branch_id = $stateParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
        load_categories();
      })

      function load_categories(){
        CategoryService.query($scope.branch_id, function(categories){
          $scope.categories = categories
          set_default_category();
          load_product()
        })
      }

      //
      // 添加估清后，要从可选估清列表中去掉，反之，要添加
      // 对有规格类型的，不需要弹出选规格类型的菜单
      //

      // 禁选套餐
      $scope.product_choose_config = {
        choose_ways_filter :{value: '!combo'},
        choose_variant: true
      };

      function add(itemable){
        EstimateClear.add({ branch_id: $scope.branch_id }, { variant_id: itemable.itemable_id }).$promise.then(function(data){
          $scope.variants.push(data.variant);
          ProductService.updateCache($scope.branch_id, data.product)
          $scope.$emit("event:product_choose:refresh_product", data.product);
        });
      }

      function add_reciprocal(itemable, quantity){
        EstimateClear.add_reciprocal({branch_id: $scope.branch_id}, {variant_id: itemable.itemable_id, quantity: quantity }).$promise.then(function(data){
          Box.alert("数量估清成功")
          $scope.variants.push(data.variant);
          ProductService.updateCache($scope.branch_id, data.product)
          $scope.$emit("event:product_choose:refresh_product", data.product);
        });
      }

      $scope.remove_reciprocal = function(itemable){
        EstimateClear.remove_reciprocal({branch_id: $scope.branch_id}, {variant_id: itemable.itemable_id}).$promise.then(function(data){
          Box.alert("成功去除数量估清,库存自动加满(999999)")
          $scope.variants = $filter('filter')($scope.variants, {id: '!' + data.variant.id})
          ProductService.updateCache($scope.branch_id, data.product)
          $scope.$emit("event:product_choose:refresh_product", data.product);
        });
      }

      $scope.$on('event:choose_itemable', function(event, itemable){
        $scope.estimate_clear_modal.open(itemable)
      });

      $scope.$on("event:choose_itemable_with_estimate_clear",function(event, variant){
        $scope.remove(variant)
      })

      $rootScope.$on('event:estimate_clear:reload', function(){
        EstimateClear.query({branch_id: $scope.branch_id}).$pomise.then(function(variants) {
          $scope.variants = variants;
        });
      });

      EstimateClear.query({branch_id: $scope.branch_id}).$promise.then(function(variants) {
        $scope.variants = variants;
        $scope.$emit("event:product_info:reload")
      });

      $scope.remove = function(variant){
        Box.confirm('确定要去除 "' + variant.name + '" 的沽清吗？', function(){
          EstimateClear.remove({branch_id: $scope.branch_id}, { variant_id: variant.id}).$promise.then(function(data){
            Box.alert("成功去除估清")
            $scope.variants = $filter('filter')($scope.variants, {id: '!' + data.variant.id})
            ProductService.updateCache($scope.branch_id, data.product)
            $scope.$emit("event:product_choose:refresh_product", data.product);
          });
        })
      };

      $scope.clear = function(branch){
        Box.confirm("是否清除全部估清记录？", function(){
          EstimateClear.clear({branch_id: $scope.branch_id}).$promise.then(function(data){
            ProductService.queryAll($scope.branch_id).then(function(products){
              var productShouldClear = []
              var selected;
              products.forEach(function(product){
                var allVariantForProduct = product.variants
                selected = false;
                for(var i=0; i< allVariantForProduct.length; ++i){
                  var variantInProduct = allVariantForProduct[i];
                  for(var j=0; j< $scope.variants.length; ++j){
                    var variant = $scope.variants[j]
                    if (variantInProduct.id == variant.id){
                      product.estimate_clear = false
                      variantInProduct.estimate_clear = false
                      productShouldClear.push(product);
                      selected = true
                      break;
                    }
                  }
                  if (selected){
                    break;
                  }
                }
              });

              productShouldClear.forEach(function(product){
                ProductService.updateCache($scope.branch_id, product);
                $scope.$emit("event:product_choose:refresh_product", product);
              });
              $scope.variants = []
            });
          });
        })
      };


      $scope.estimate_clear_modal = {
        show: false,
        type: "direct",
        reciprocal: false,
        stock_quantity: undefined,
        variant: undefined,
        change_type: function(type){
          this.type = type;
        },
        open: function(variant){
          this.show = true
          this.type = "direct"
          this.variant = variant
          this.stock_quantity = variant.stock_quantity
          this.reciprocal =  variant.estimate_clear_reciprocal
        },
        submit: function(){
          if(this.type == "direct"){
            add(this.variant)
            this.show=false
          }
          if(this.type == "add_reciprocal"){
            if(this.stock_quantity > 0 ){
              add_reciprocal(this.variant, this.stock_quantity)
              this.show=false
            }else{
              Box.alert("库存量必须为正数")
            }
          }
          if (this.type == "remove_reciprocal") {
            $scope.remove_reciprocal(this.variant)
            this.show=false
          }
        },
        close: function(){
          this.show = false
        }
      }



      // ---------product_choose
      // 由调用者定义的可复写配置
      // $scope.product_choose_config = angular.extend({
      //   //choose_ways_filter: {},
      //   choose_variant: true,
      // },$scope.product_choose_config);

      var per_page = WebposConst.per_page * 5
      $scope.choose_ways = [
        { value: 'variant', label: '单品' },
        { value: 'combo', label: '套餐' }
      ];

      if ($scope.product_choose_config.choose_ways_filter) {
        $scope.choose_ways = $filter('filter')($scope.choose_ways, $scope.product_choose_config.choose_ways_filter);
      }

      $scope.filter_key = "";
      $scope.active_choose_way = $scope.choose_ways[0]
      $scope.active_product = null
      // category
      $scope.categories = []
      $scope.active_category = null
      $scope.active_sub_category = null
      $scope.category_products = []

      // combo
      $scope.is_load_combo = false
      $scope.combos = []
      $scope.active_combo = null

      function set_category_cache(){
        var last_active_category_id = undefined;
        if($scope.active_category){
          last_active_category_id = $scope.active_category.id;
        }
        var last_active_sub_category_id;
        if ($scope.active_sub_category) {
          last_active_sub_category_id = $scope.active_sub_category.id;
        }
        LocalStorageCache.set('last_active_category_id', last_active_category_id);
        LocalStorageCache.set('last_active_sub_category_id', last_active_sub_category_id);
      }

      function get_category_cache(){
        var last_active_category_id = LocalStorageCache.get('last_active_category_id');
        var last_active_sub_category_id = LocalStorageCache.get('last_active_sub_category_id');
        return [last_active_category_id, last_active_sub_category_id]
      }

      $rootScope.$on("event:estimate_clear", function(e, msg){
        if(['clear', 'add', 'remove'].indexOf(msg.action) != -1){
          if('clear' == msg.action){
            ProductService.clear($scope.branch_id);
            set_category_cache();
          }else{
            ProductService.set_estimate_clear($scope.branch_id, msg);
          }
          load_categories();
        }
      });

      $rootScope.$on("event:product_choose:refresh_product", function(event, product){
        var i;
        var products = $scope.current_category().products;
        for(i=0;i<products.length;i++){
          var pre_product=products[i]
          if(pre_product.id == product.id){
            products[i] = product
          }
        }
        products = $scope.search_products
        for(i=0;i<products.length;i++){
          var pre_product=products[i]
          if(pre_product.id == product.id){
            products[i] = product
          }
        }
        $scope.active_product = null
      });

      $rootScope.$on("event:product_info:reload",function(){
        ProductService.clear($scope.branch_id);
        set_category_cache();
        $scope.branch_id = $stateParams.branch_id
        BranchService.get($scope.branch_id, function(branch){
          $scope.branch = branch
          load_categories();
          });
      })



      function set_default_category(){
        var last_active_category_id = get_category_cache()[0];
        var last_active_sub_category_id = get_category_cache()[1];
        if (last_active_category_id) {
          var active_categories = $filter('filter')($scope.categories, {id: last_active_category_id}, true);
          if (active_categories && active_categories.length > 0) {
            $scope.change_active_category(active_categories[0]);
            if (last_active_sub_category_id) {
              var active_sub_categories = $filter('filter')($scope.active_category.subs, {id: last_active_sub_category_id}, true);
              if (active_sub_categories && active_sub_categories.length > 0) {
                $scope.change_active_sub_category(active_sub_categories[0]);
              }
            }
          }
        }

        // 如果没有记忆上次选择分类，则选中第一项
        if (!$scope.active_category) {
          $scope.active_category = $scope.categories[0]
        }
      }

      function load_product(){
        $scope.reset_filter_key()
        $scope.active_product = null
        var current_category = $scope.current_category();
        if(!current_category){
          Box.alert("尚未设置该门店的分类数据");
          return;
        }
        if(current_category.products){
          check_default_sub_category()
          return
        }else{
          current_category.page = 1
          ProductService
            .query($scope.branch_id, current_category.id)
            .then(function(products){
              current_category.products = filter_products(products);
              check_default_sub_category()
            })
        }
      }

      function filter_products(products){
        if(!products){ return []}
        var ban_product_ids = $scope.ban_product_ids || []
        if(ban_product_ids.length == 0){
          return products;
        }else{
          return products.filter(function(product){
            return ban_product_ids.indexOf(product.id) == -1
          })
        }
      }

      $scope.syncProducts = function(){
        CategoryService
          .clear($scope.branch_id)
          .then(function(){
            ProductService
              .clear($scope.branch_id)
              .then(function(){
                var current_category = $scope.current_category();
                if(current_category){
                  current_category.products = undefined;
                }
                load_categories();
              })
          })
      }

      $scope.change_active_choose_way = function(choose_way){
        $scope.active_choose_way = choose_way
        $scope.reset_filter_key()
      }

      function check_default_sub_category(){
        if($scope.current_category() && $scope.current_category().products && $scope.current_category().products.length == 0 && $scope.active_sub_category == null && $scope.active_category.subs.length > 0){
          $scope.active_sub_category = $scope.active_category.subs[0]
          load_product()
          set_category_cache()
        }
      }

      $scope.is_show_default_sub_category = function(category){
        return category && category.subs.length > 0 && category.products && category.products.length > 0
      }

      $scope.current_category = function(){
        return $scope.active_sub_category || $scope.active_category
      }

      $scope.change_active_category = function(category){
        $scope.active_category = category
        $scope.active_sub_category = null
        load_product()
        set_category_cache()
      }

      $scope.change_active_sub_category = function(sub){
        $scope.active_sub_category = sub
        load_product()
        set_category_cache()
      }

      $scope.show_load_next_page = function(){
        var category = $scope.current_category()
        return category && category.page && category.products &&
              (category.page * per_page === category.products.length) &&
              $scope.active_product === null
      }

      $scope.load_next_page = function(){
        var category = $scope.current_category()
        category.page ++
        ProductService
          .query($scope.branch_id, category.id)
          .then(function(products){
            category.products = category.products.concat( filter_products(products) )
          })
      }

      // search
      $scope.search_key = null
      $scope.search_products = []
      var clear_watch_search_key = $scope.$watch("search_key", function(search_key){
        if($scope.search_key){
          ProductService
            .queryByNameAbbr($scope.branch_id, $scope.search_key)
            .then(function(products){
              $scope.search_products = filter_products(products);
            })
        }else{
          $scope.search_products = []
        }
      })

      $scope.$on("event:choose_itemable:handle_finish", function(event){
        $scope.search_key = null;
      })

      // common
      $scope.change_active_product = function(product){
        if(product.variants.length == 1 || !$scope.product_choose_config.choose_variant){
          //$scope.active_product = product
          $scope.choose_variant(product.variants[0])
        }else{
          $scope.active_product = product
        }
      }

      $scope.choose_variant = function(variant){
        if(variant.estimate_clear){
          $scope.$emit("event:choose_itemable_with_estimate_clear",variant)
        }else{
          $scope.active_product = null;
          $scope.$emit("event:choose_itemable", variant);
          }
        }

      $scope.reset_filter_key = function(){
        $scope.filter_key = ""
      }

      var pinying_search_product = function(e){
        var focus_input_length = $("input:focus").length
        if(focus_input_length == 0
          && /* 组合键没按下*/ !(e.shiftKey || e.ctrlKey || e.altKey || e.metaKey)
        ){
          //console.log("-->pinyin search product<--")
          //console.log(e.keyCode)
          var code = e.keyCode
          var ENTER = 13
          // a-z 65-90
          // 0-9 48-57
          // numpad 0-9 96-105
          if(code >= 48 && code <= 57){
            $scope.filter_key += code - 48
          }else if(code >= 96 && code <= 105){
            $scope.filter_key += code - 96
          }else if(code >= 65 && code <= 90){
            $scope.filter_key += String.fromCharCode(code).toLowerCase()
          }else if(code == 8){
            if($scope.filter_key.length > 0){
              $scope.filter_key = $scope.filter_key.slice(0, $scope.filter_key.length - 1)
            }
          }
          // console.log($scope.filter_key)
          e.preventDefault();
          $rootScope.$apply();
        }
      }
      $(document).on("keydown", pinying_search_product)
      $scope.$on("$destroy", function(){
        $(document).off("keydown", pinying_search_product)
        clear_watch_search_key()
      })

      $rootScope.focus('.search_key input')

      $scope.current_category_products_with_filter = function(){
        if($scope.current_category()){
          var products = null;
          if($scope.filter_key){
            products = $scope.current_category().products.filter(function(product){ return product.name_abbr.startsWith($scope.filter_key)})
          }else{
            products = $scope.current_category().products
          }
          return filter_products(products)
        }
      }

      $scope.estimate_clear_page = {
        show_stock_quantity: true,
        stock_quantity_str: function(variant){
          if(variant.estimate_clear_reciprocal){
            return variant.stock_quantity + " [数]"
          }else{
            return variant.stock_quantity
          }
        }
      }

      $scope.show_disabled = function(product){
        if(product.estimate_clear){
          return true
        }
        if(product.variants.length == 1 && product.variants[0].estimate_clear == true){
          return true
        }
        return false
      }


    }])
