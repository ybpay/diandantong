WebposModules.add_controller('branch_setting')
angular.module('webpos.controllers.branch_setting', []).
  controller('BranchSettingController',
    ['$rootScope','$scope', '$filter', 'ProductService', '$stateParams','BranchService','CategoryService', 'LocalStorageCache', 'LitpWaitTimeService',
    function($rootScope, $scope, $filter, ProductService, $stateParams, BranchService, CategoryService, LocalStorageCache, LitpWaitTimeService){

      $scope.choose_ways = [
        { value: 'variant', label: '单品' },
      ];

      $scope.filter_key = "";
      $scope.active_choose_way = $scope.choose_ways[0]
      $scope.active_product = null
      // category
      $scope.categories = []
      $scope.active_category = null
      $scope.active_sub_category = null
      $scope.category_products = []

      $scope.branch_id = $stateParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
        load_categories();
      });

      function load_categories(){
        CategoryService.query($scope.branch_id, function(categories){
          $scope.categories = categories
          set_default_category();
          load_product()
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
        LocalStorageCache.set('last_active_category_id', last_active_category_id);
        LocalStorageCache.set('last_active_sub_category_id', last_active_sub_category_id);
      }

      function get_category_cache(){
        var last_active_category_id = LocalStorageCache.get('last_active_category_id');
        var last_active_sub_category_id = LocalStorageCache.get('last_active_sub_category_id');
        return [last_active_category_id, last_active_sub_category_id]
      }

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

      var clear_choose_itemable_finish_listener = $scope.$on("event:choose_itemable:handle_finish", function(event){
        $scope.search_key = null;
      })

      // common
      $scope.change_active_product = function(product){
        if(product.variants.length == 1){
          //$scope.active_product = product
          $scope.choose_variant(product.variants[0])
        }else{
          $scope.active_product = product
        }
      }

      $scope.choose_variant = function(variant){
        $scope.wait_time_modal.open(variant)
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
        clear_choose_itemable_finish_listener()
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

      $scope.show_disabled = function(product){
        if(product.estimate_clear){
          return true
        }
        if(product.variants.length == 1 && product.variants[0].estimate_clear == true){
          return true
        }
        return false
      }

      $scope.wait_time_modal = {
        show: false,
        wait_minute: 10,
        page: 1,
        minutes: function(){
          var ms = [];
          for(var i=0;i<60;i++)
            ms[i] = i+1;
          var minutes = _.map(ms, function(m){ return m + 60 * ($scope.wait_time_modal.page - 1); })
          return minutes;
        },
        next_page: function(){ this.page ++; },
        pre_page: function(){ if(this.page > 1) this.page --; },
        open: function(variant){
          this.page = 1
          this.variant = variant
          this.show = true
        },
        choose_minute: function(minute){
          LitpWaitTimeService.set(this.variant.id, minute)
          this.show = false
        }
      }

      $scope.get_wait_minute_of_product = function(product){
        if(product.variants.length == 1){
          return $scope.get_wait_minute_of_variant(product.variants[0])
        }
      }

      $scope.get_wait_minute_of_variant = function(variant){
        return LitpWaitTimeService.get(variant.id) || $scope.branch.litp_warning_wait_minitue;
      }

    }])
