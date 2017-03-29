WebposModules.add_controller('shop')
angular.module('webpos.controllers.shop', []).
  controller('shopController', ['$rootScope', '$scope', 'Branch',
    function($rootScope, $scope, Branch){
      $rootScope.navigation_msg = "请选择要操作的门店";
      $scope.branches = []
      $rootScope.set_branch(null)
      if($rootScope.account){
        if ($rootScope.account.branches.length == 1){
          $rootScope.go_branch($rootScope.account.branches[0])
        } else {
          Branch.query({}, function(branches){
            $scope.branches = branches;
            if(branches.length == 0){
              $rootScope.alert("请检查是否创建门店或门店是否已全部过期")
            }
          })
        }
      }
    }])
