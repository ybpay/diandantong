Ddt.controller('exchangeNavController',
  ['$rootScope', '$scope', '$location', 'ShopService', 'UserService',
  function($rootScope, $scope, $location, ShopService, UserService){

    $rootScope.title = '兑换中心';

    ShopService.get(function(shop){
      $scope.shop = shop;
    })

    UserService.get(function(user){
      $scope.user = user;
      console.log($scope.user)
    })

    var btns = Base.newBtns($location);

    btns.push({
      img: '/images/ddt/my/coupons.png',
      label: "优惠券",
      href: '/user/credits'
    });
    $scope.item_groups = btns.group();

  }])
