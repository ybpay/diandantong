WebposModules.add_controller('account')
angular.module('webpos.controllers.account', []).
  controller('accountController', ['$rootScope', '$scope', 'AccountService', 'Branch',
    function($rootScope, $scope, AccountService, Branch){
      if($rootScope.account){
        $rootScope.go('/')
      }
      $scope.account = {
        login: '',
        password: '',
        remember_me: false
      };

      $scope.login_main = get_ddb_cache('login_main')
      var login_sub = get_ddb_cache('login_sub')
      if(login_sub){
        $scope.login_sub = login_sub
      }else{
        $scope.login_sub = '';
      }
      $scope.login_type = 'sub'

      $scope.submit = function(){
        set_ddb_cache('login_main', $scope.login_main)
        set_ddb_cache('login_sub', $scope.login_sub)
        if($scope.login_type == 'sub'){
          $scope.account.login = $scope.login_main + ($scope.login_sub.length > 0 ? ":" + $scope.login_sub : "");
        }else if($scope.login_type == 'main'){
          $scope.account.login = $scope.login_main
        }
        AccountService.sign_in($scope.account, function(resp){
          // 如果是服务员/排号员，只他只能管理一个商户，到排号界面
          Branch.query({}, function(branches){
            $rootScope.has_multi_branches = branches.length > 1
            if (branches.length == 1){
              if (AccountService.is_role('queue_waiter', true)) {
                $rootScope.go('/branches/' + branches[0].id + '/guest_queues');
              } else {
                $rootScope.go('/branches/' + branches[0].id + '/eat_in_hall');
              }
            } else {
              $rootScope.go('/')
            }
          });
        })
      }
    }])
