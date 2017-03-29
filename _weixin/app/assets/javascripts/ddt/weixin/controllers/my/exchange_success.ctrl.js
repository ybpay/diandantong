Ddt.controller('exchangeSuccess',
  ['$rootScope', '$scope',
  function($rootScope, $scope){
    $rootScope.title = '兑换成功'
    $scope.hint = '兑换成功'
    $scope.confirm_label = "返回会员";
    $scope.can_confirm = true;
    $scope.can_back = false;
    $scope.confirm = function(){$rootScope.go('/user/profile')}
  }])
