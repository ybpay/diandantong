CrmModules.add_controller('recharge_products')
angular.module('crm.controllers.recharge_products', []).
  controller('RechargeProductsController', ['$rootScope','$scope','RechargeProduct', '$mdDialog', 'Box',
    function($rootScope, $scope, RechargeProduct, $mdDialog, Box){
      $scope.recharge_products = [];
      $scope.query_params = {};
      RechargeProduct.query($scope.query_params).$promise.then(function(resp){
        $scope.recharge_products = resp
      })

      $scope.$on("event:recharge_product:create", function(event, new_recharge_product){
        $scope.recharge_products.push(new_recharge_product)
        Box.toast("添加成功")
      })

      $scope.$on("event:recharge_product:update", function(event, new_recharge_product){
        Box.toast("更新成功")
        angular.forEach($scope.recharge_products, function(recharge_product){
          if(new_recharge_product.id == recharge_product.id){
            var index = $scope.recharge_products.indexOf(recharge_product)
            $scope.recharge_products[index] = new_recharge_product
          }
        })
      })

      $scope.new_recharge_product = function($event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/recharge_product_form.html"),
          clickOutsideToClose:true,
          controller: ["$rootScope","$scope","$mdDialog","RechargeProductModel","Branch","BranchGroup", function($rootScope, $scope, $mdDialog, RechargeProductModel, Branch, BranchGroup) {
            $scope.recharge_product = RechargeProductModel.build()
            $scope.close = function() {
              $mdDialog.hide();
            }
            $scope.branch_select_options = {
              query: function(query){
                Branch.query({"q[name_cont]": query.term }).$promise.then(function(resp){
                  query.callback({ results: resp })
                })
              }
            }
            $scope.branch_group_select_options = {
              query: function(query){
                BranchGroup.query({"q[name_cont]": query.term }).$promise.then(function(resp){
                  query.callback({ results: resp })
                })
              }
            }
            $scope.submit = function(){
              RechargeProduct.save({}, { recharge_product: RechargeProductModel.to_params($scope.recharge_product) }).$promise.then(function(recharge_product){
                $mdDialog.hide();
                $rootScope.$broadcast("event:recharge_product:create", recharge_product)
              })
            }
          }]
        });
      }

      $scope.edit_recharge_product = function(recharge_product, $event){
        $mdDialog.show({
          parent: angular.element(document.body),
          targetEvent: $event,
          templateUrl: template_url("/dialogs/recharge_product_form.html"),
          clickOutsideToClose:true,
          controller: ["$rootScope","$scope", "$mdDialog","RechargeProductModel","Branch","BranchGroup", function($rootScope, $scope, $mdDialog, RechargeProductModel, Branch, BranchGroup) {
            $scope.recharge_product = angular.copy(recharge_product)
            $scope.close = function() {
              $mdDialog.hide();
            }
            $scope.branch_select_options = {
              query: function(query){
                Branch.query({"q[name_cont]": query.term }).$promise.then(function(resp){
                  query.callback({ results: resp })
                })
              }
            }
            $scope.branch_group_select_options = {
              query: function(query){
                BranchGroup.query({"q[name_cont]": query.term }).$promise.then(function(resp){
                  query.callback({ results: resp })
                })
              }
            }
            $scope.submit = function(){
              RechargeProduct.update({id: $scope.recharge_product.id}, { recharge_product: RechargeProductModel.to_params($scope.recharge_product) }).$promise.then(function(resp){
                $mdDialog.hide();
                $rootScope.$broadcast("event:recharge_product:update", resp)
              })
            }
          }]
        });
      }

      $scope.destroy_recharge_product = function(recharge_product){
        Box.confirm("确认删除"+ recharge_product.name + "?").then(function(){
          RechargeProduct.destroy({id: recharge_product.id}, {}, function(){
            var index = $scope.recharge_products.indexOf(recharge_product)
            $scope.recharge_products.splice(index, 1)
            Box.toast("删除成功")
          })
        })
      }

      $scope.toggle_action = function(recharge_product){
        angular.forEach($scope.recharge_products, function(rp){
          rp.show_action = (rp.id == recharge_product.id) && !rp.show_action
        })
      }
    }
  ])