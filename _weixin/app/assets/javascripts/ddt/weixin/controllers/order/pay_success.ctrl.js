
Ddt.controller('paySuccessController',
  ['$rootScope', '$scope', '$routeParams',
  function($rootScope, $scope, $routeParams){
    var p = $routeParams;
    $rootScope.title = '支付成功';

    $rootScope.hint = '订单支付成功';
    if('recharge' == p.order_type){
      $scope.confirm_label = '查看详情';
      $scope.back_label = '返回会员';
      $rootScope.hint = '充值成功, 预计5分钟内到账.';
      $scope.back = function(){
        $rootScope.go_page('my', '/user/profile')
      }
    }else{
      $scope.back_label = '返回商家'
      $scope.back = function(){
        $rootScope.go_page('main', '/branches/'+p.branch_id)
      }
    }

    $scope.confirm = function(){ $rootScope.go('/branches/'+p.branch_id+'/orders/'+p.order_type+'/'+p.order_id)}
    if(p.order_type == 'fastfood'){
      $scope.confirm();
    }

    $scope.can_back = true;
    $scope.can_confirm = true;


  }])

// TODO 菜品打折价星号
