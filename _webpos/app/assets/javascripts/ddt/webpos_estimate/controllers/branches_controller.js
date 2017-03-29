WebposModules.add_controller('branches')
angular.module('webpos.controllers.branches', []).
  controller('BranchesController', ['$rootScope', '$scope', 'Branch', 'Box', '$state',
    function($rootScope, $scope, Branch, Box, $state){
      $scope.navigation_msg = "请选择要操作的门店";
      $scope.branches = []
      $rootScope.set_branch(null)

      $scope.go_branch = function(branch){
        $state.go("shop.estimate", { branch_id: branch.id })
      }

      if($rootScope.account){
        if ($rootScope.account.branches.length == 1) {
          $scope.go_branch($rootScope.account.branches[0])
        } else {
          Branch.query().$promise.then(function (branches) {
            $scope.branches = branches;
            if (branches.length == 0) {
              Box.alert("请检查是否创建门店或门店是否已全部过期")
            }
          })
        }
      }


    }])