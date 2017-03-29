WebposModules.add_controller('estimate_clear')
angular.module('webpos.controllers.estimate_clear', []).
  controller('estimateClearController',
  ['$rootScope','$scope','$routeParams','BranchService', 'EstimateClearService', '$filter','ProductService',
    function($rootScope, $scope, $routeParams, BranchService, EstimateClearService, $filter, ProductService){
      // 跳转
      // $rootScope.go_path("/webpos/estimate#/shop/branches/"+$routeParams.branch_id+"/estimate")

      $scope.branch_id = $routeParams.branch_id
      BranchService.get($scope.branch_id, function(branch){
        $scope.branch = branch
      })

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
        EstimateClearService.add($scope.branch_id, itemable.itemable_id, function(data){
          $scope.variants.push(data.variant);
          ProductService.updateCache($scope.branch_id, data.product)
          $scope.$emit("event:product_choose:refresh_product", data.product);
        });
      }

      function add_reciprocal(itemable, quantity){
        EstimateClearService.add_reciprocal($scope.branch_id, itemable.itemable_id, quantity, function(data){
          $rootScope.alert("数量估清成功")
          $scope.variants.push(data.variant);
          ProductService.updateCache($scope.branch_id, data.product)
          $scope.$emit("event:product_choose:refresh_product", data.product);
        });
      }

      $scope.remove_reciprocal = function(itemable){
        EstimateClearService.remove_reciprocal($scope.branch_id, itemable.itemable_id, function(data){
          $rootScope.alert("成功去除数量估清,库存自动加满(999999)")
          $scope.variants = $filter('filter')($scope.variants, {id: '!' + data.variant.id})
          ProductService.updateCache($scope.branch_id, data.product)
          $scope.$emit("event:product_choose:refresh_product", data.product);
        });
      }

      var clear_choose_itemable_listener = $scope.$on('event:choose_itemable', function(event, itemable){
        $scope.estimate_clear_modal.open(itemable)
      });

      var clear_choose_itemable_with_estimate_clear_listener = $scope.$on("event:choose_itemable_with_estimate_clear",function(event, variant){
        $scope.remove(variant)
      })

      var clear_estimate_clear_reload_listener = $rootScope.$on('event:estimate_clear:reload', function(){
        EstimateClearService.gets($scope.branch_id, function(variants) {
          $scope.variants = variants;
        });
      });

      $scope.$on("$destroy", function(){
        clear_choose_itemable_listener()
        clear_choose_itemable_with_estimate_clear_listener()
        clear_estimate_clear_reload_listener()
      })

      EstimateClearService.gets($scope.branch_id, function(variants) {
        $scope.variants = variants;
        $scope.$emit("event:product_info:reload")
      });

      $scope.remove = function(variant){
        $rootScope.confirm('确定要去除 "' + variant.name + '" 的沽清吗？', function(){
          EstimateClearService.remove($scope.branch_id, variant.id, function(data){
            $rootScope.alert("成功去除估清")
            $scope.variants = $filter('filter')($scope.variants, {id: '!' + data.variant.id})
            ProductService.updateCache($scope.branch_id, data.product)
            $scope.$emit("event:product_choose:refresh_product", data.product);
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
              $rootScope.alert("库存量必须为正数")
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

    }]);
