WebposModules.add_cell('product_choose')
angular.module('webpos.cells.product_choose', []).
  controller('productChooseCell',
    ['$rootScope','$scope', '$filter', '$timeout', '$location' , '$cacheFactory', 'NotifyService', 'ProductService', '$routeParams','BranchService','CategoryService','ComboService', 'VariantPackageService',
    function($rootScope, $scope, $filter, $timeout, $location , $cacheFactory, NotifyService, ProductService, $routeParams, BranchService, CategoryService, ComboService, VariantPackageService){

      // 由调用者定义的可复写配置
      $scope.product_choose_config = angular.extend({
        //choose_ways_filter: {},
        choose_variant: true,
      },$scope.product_choose_config);

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

      $scope.branch_id = $routeParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
        initialize();
      });

      function init_categories(){
        // TODO: 利用 $wpRepeat 来管理 cache
        $scope.categories_dom_cache = $cacheFactory.get('product-choose-categories-dom-cache')
        if (!$scope.categories_dom_cache){
          $scope.categories_dom_cache = $cacheFactory('product-choose-categories-dom-cache')
        }
      }
      init_categories();

      function initialize(){
        if(ProductService.need_sync($scope.branch_id)){
          console.log('syncProducts')
          $scope.syncProducts()
        }else{
          var cache_ids = get_category_cache()
          var active_id = (cache_ids[1] || cache_ids[0])
          ProductService.query($scope.branch_id,  active_id || -1)
          .then(function(products){
            if(active_id){
              $scope.products = products;
            }
            load_categories();
          });
        }
      }


      function load_categories(){
        CategoryService.query($scope.branch_id, function(categories, fromCache){
          $scope.categories = categories
          set_default_category();
          load_product()
          if (!fromCache) {
            $scope.categories_dom_cache.removeAll();
          }
        })
      }

      function set_category_cache(){
        var last_active_category_id = undefined;
        if($scope.active_category){
          last_active_category_id = $scope.active_category.id;
        }
        var last_active_sub_category_id;
        if ($scope.active_sub_category) {
          last_active_sub_category_id = $scope.active_sub_category.id;
        }
        $rootScope.set_cache('last_active_category_id', last_active_category_id);
        $rootScope.set_cache('last_active_sub_category_id', last_active_sub_category_id);
      }

      function update_category_products(){
        var active_category = $scope.current_category();
        if(active_category){
          ProductService.query($scope.branch_id, active_category.id)
            .then(function(products){
              active_category.products = products;
              $scope.products = products;
            });
        }
      }

      function get_category_cache(){
        var last_active_category_id = $rootScope.get_cache('last_active_category_id');
        var last_active_sub_category_id = $rootScope.get_cache('last_active_sub_category_id');
        return [last_active_category_id, last_active_sub_category_id]
      }

      var clear_product_choose_reload_listener = $rootScope.$on("event:estimate_clear", function(e, msg){
        if(['clear', 'add', 'remove'].indexOf(msg.action) != -1){
          if('clear' == msg.action){
            ProductService.clear($scope.branch_id).then(function(){
              update_category_products()
              load_categories();
            });
          }else{
            ProductService.set_estimate_clear($scope.branch_id, msg).then(function(){
              update_category_products()
              load_categories();
            });
          }
        }
      });

      var clear_product_choose_refresh_listener = $rootScope.$on("event:product_choose:refresh_product", function(event, product){
        var i;
        var products = $scope.current_category().products;
        for(i=0;i<products.length;i++){
          var pre_product=products[i]
          if(pre_product.id == product.id){
            products[i] = product
          }
        }
        products = $scope.products
        for(i=0;i<products.length;i++){
          var pre_product=products[i]
          if(pre_product.id == product.id){
            products[i] = product
          }
        }
        $scope.active_product = null
      });

      var clear_product_info_reload_listener = $rootScope.$on("event:product_info:reload",function(){
        ProductService.clear($scope.branch_id);
        set_category_cache();
        $scope.branch_id = $routeParams.branch_id
        BranchService.get($scope.branch_id, function(branch){
          $scope.branch = branch
          CategoryService.query($scope.branch_id, function(categories){
            $scope.categories = categories
            set_default_category();
            load_product()
            })
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
          $rootScope.alert("尚未设置该门店的分类数据");
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
                update_category_products();
                load_categories();
              })
          })
        ComboService.clear_cache($scope.branch_id)
        $scope.load_combos();
        $scope.active_combo = null
      }


      NotifyService.set_message_hander_in_scope($scope, "PRODUCT_UPDATE_NOTIFICATION", function(message){
        console.log(message);
        if(message.branch_id == $scope.branch_id){
          $rootScope.alert("发现后台菜单发生变更，系统自动进行菜品同步");
          $scope.syncProducts();
        }
      });

      $scope.change_active_choose_way = function(choose_way){
        $scope.active_choose_way = choose_way
        $scope.reset_filter_key()
        if(choose_way.value === 'combo'){
          if(!$scope.is_load_combo){
            $scope.load_combos()
          }
        }
      }

      $scope.load_combos = function(){
        ComboService.query($scope.branch_id, function(combos){
          $scope.combos = combos
          $scope.is_load_combo = true
          angular.forEach($scope.combos, function(combo){
            auto_add_variant_to_combo(combo, false)
          })
        })
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
        if ($scope.active_category) {
          $('.category-btn-' + $scope.active_category.id).removeClass('active')
        }
        $('.category-btn-' + category.id).addClass('active')
        $scope.active_category = category
        $scope.active_sub_category = null
        load_product()
        $scope.$emit('event:product:update')
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
      $scope.products = []

      var update_search_product_promise = null;
      var products_container = $(".products")
      var clear_watch_search_key = $scope.$watch("search_key", function(){
        if (update_search_product_promise) {
          $timeout.cancel(update_search_product_promise)
        }
        products_container.hide();
        update_search_product_promise = $timeout(function(){
          if($scope.search_key){
            ProductService
              .queryByNameAbbr($scope.branch_id, $scope.search_key)
              .then(function(products){
                $scope.products = filter_products(products);
              })
          }else{
            $scope.update_category_products_with_filter()
          }
          products_container.show();
          update_search_product_promise = null;
        }, 200);
      })

      var clear_choose_itemable_finish_listener = $scope.$on("event:choose_itemable:handle_finish", function(event){
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

      //combo
      $scope.change_active_combo = function(combo){
        $scope.active_combo = combo
      }

      $scope.add_combo_item_variant = function(combo_item, variant, with_submit){
        if(typeof with_submit == 'undefined'){
          with_submit = true;
        }
        if(combo_item.quantity == combo_item.select_count){
          if(variant.quantity > 0){
            combo_item.quantity = combo_item.quantity - variant.quantity
            variant.quantity = 0
          }else{
            if(combo_item.quantity == 1){
              angular.forEach(combo_item.variants, function(variant){
                variant.quantity = 0
              })
              variant.quantity = 1;
            }
          }
        }else{
          combo_item.quantity ++
          variant.quantity ++
        }
        if(combo_item.quantity == combo_item.select_count){
          combo_item.hide_variants = true
        }

        if(with_submit && $scope.can_add_combo_package($scope.active_combo)){
          $scope.add_combo_package($scope.active_combo);
        }
      }

      $scope.toggle_combo_item_hide_variants = function(combo_item){
        combo_item.hide_variants = !combo_item.hide_variants;
      }

      $scope.get_content_of_combo_item = function(combo_item){
        var variants = []
        angular.forEach(combo_item.variants, function(variant){
          if(variant.quantity > 0){
            variants.push(variant.name + '*' + variant.quantity)
          }
        })
        return  variants.join(',')
      }

      function auto_add_variant_to_combo(combo, with_submit){
        angular.forEach(combo.combo_items, function(combo_item){
          angular.forEach(combo_item.variants, function(variant){
            variant.quantity = 0
          })
          combo_item.quantity = 0
          combo_item.hide_variants = false
          if(combo_item.is_necessary && combo_item.select_count >= 1 && combo_item.variants.length == 1){
            for(var i=0;i<combo_item.select_count;i++){
              $scope.add_combo_item_variant(combo_item, combo_item.variants[0], with_submit);
            }
          }
        })
      }

      $scope.add_combo_package = function(combo){
        if($scope.can_add_combo_package(combo)){
          var params = []
          var contents = ""
          angular.forEach(combo.combo_items, function(combo_item){
            angular.forEach(combo_item.variants, function(variant){
              if(variant.quantity > 0){
                params.push({
                  combo_item_id: combo_item.id,
                  quantity: variant.quantity,
                  variant_id: variant.id
                })
                contents += variant.name + "*" + variant.quantity + "<br/>"
              }
            })
          })
          $rootScope.confirm("确认添加套餐 "+combo.name+ " ?<br/>"+contents, function(){
            ComboService.add_combo_package($scope.branch_id, combo.id, params, function(combo_package){
              $scope.$emit("event:choose_itemable", combo_package)
              auto_add_variant_to_combo(combo, false)
            })

          })
        }else{
          $rootScope.alert(combo.combo_items.length==0 ? "该套餐还没设置组合选项，请管理人员在后台配置" : "套餐数量不正确")
        }
      }

      $scope.can_add_combo_package = function(combo){

        if(!combo) return false;
        if(combo.combo_items.length == 0){return false;}
        var result = true
        angular.forEach(combo.combo_items, function(combo_item){
          if(combo_item.is_necessary && combo_item.quantity !== combo_item.select_count){
            result = false
          }
        })
        return result
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

      var unbind_hide_modal = $rootScope.$on('modal:hide', function(e, modal_type){
        $rootScope.focus('.search_key input')
      })
      var unbind_hotkey_search_key = $rootScope.bind_key('enter',function(){
        if($scope.search_key && $scope.products.length == 1){
          $scope.change_active_product($scope.products[0])
        }
      })

      $scope.update_category_products_with_filter = function(){
        // 当 filter_key 或 current_category 改变时, 此值改变
        var currentCategory = $scope.current_category();
        if(currentCategory){
          var products = null;
          if($scope.filter_key){
            products = currentCategory.products.filter(function(product){ return product.name_abbr.startsWith($scope.filter_key)})
          }else{
            products = currentCategory.products
          }
          $scope.products = filter_products(products)
        }
      }

      var clear_watch_current_category = $scope.$watch("current_category()", $scope.update_category_products_with_filter)
      var clear_watch_filter_key = $scope.$watch("filter_key", $scope.update_category_products_with_filter)
      var clear_products_listener = $scope.$on('event:product:update', $scope.update_category_products_with_filter)

      $scope.estimate_clear_page = {
        show_stock_quantity: $location.path().includes('estimate_clear'),
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

      $scope.$on("$destroy", function(){
        $(document).off("keydown", pinying_search_product)
        if (update_search_product_promise) {
          $timeout.cancel(update_search_product_promise)
        }
        clear_watch_filter_key();
        clear_watch_current_category();
        clear_products_listener();
        clear_watch_search_key();
        clear_product_choose_reload_listener();
        clear_product_choose_refresh_listener();
        clear_product_info_reload_listener();
        clear_choose_itemable_finish_listener();
        unbind_hotkey_search_key();
        unbind_hide_modal();
      })

    }])
