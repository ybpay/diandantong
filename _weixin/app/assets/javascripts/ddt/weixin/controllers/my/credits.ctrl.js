Ddt.controller('creditsController',
  ['$rootScope', '$scope', 'UserService', 'CouponVersionService',
  function($rootScope, $scope, UserService, CouponVersionService){
    $scope.coupon_versions = [];
    $scope.default_tab = 'exchange';
    $scope.tabs = ['exchange', 'gain_log', 'exchange_log'];

    $scope.change_filter_tab = function(tab){
      $scope.tab = tab
      if(tab == 'exchange'){ get_exchange()}
      if(tab == 'gain_log'){ get_gain_log()}
      if(tab == 'exchange_log'){ get_exchange_log()}
    }

    UserService.get(function(user){
      $scope.user = user;
    })

    $scope.change_filter_tab($scope.default_tab);

    $scope.go_coupon_version = function(version){
      $rootScope.go('/user/exchange/coupon_versions/' + version.id)
    }

    function get_exchange(){
      CouponVersionService.query({
        'q[can_exchange_eq]': true
      }, function(coupon_versions){
        $scope.coupon_versions = coupon_versions;
      })
    }

    function get_gain_log(){
      UserService.get_credits_wallet_logs({
        'q[amount_gt]': 0
      }, function(logs){
        $scope.gain_logs = logs;
      })
    }

    function get_exchange_log(){
      UserService.get_credits_wallet_logs({
        'q[amount_lt]': 0
      }, function(logs){
        $scope.exchange_logs = logs;
      })

    }




  }])
