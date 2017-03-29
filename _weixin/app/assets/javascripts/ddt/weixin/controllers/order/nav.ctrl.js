"user_strict"
Ddt.controller('orderNavController',
    ['$rootScope', '$scope', '$location', 'UserService',
    function($rootScope, $scope, $location, UserService){
      $rootScope.title = '订单中心'
      var btns = Base.newBtns($location)

      UserService.get(function(user){
        $scope.user = user;
      })

      if($rootScope.has_feature('model_delivery_order')){
        btns.push({
          img: '/images/ddt/my/delivery.png',
          label: '外卖订单',
          href: '/orders/delivery'
        })
      }

      if($rootScope.has_feature('model_reservation_order')){
        btns.push({
          img: '/images/ddt/my/reservation.png',
          label: '预定订单',
          href: '/orders/reservation'
        })
      }

      if($rootScope.has_feature('model_fastfood_order')){
        btns.push({
          img: '/images/ddt/my/fastfood.png',
          label: '快餐订单',
          href: '/orders/fastfood'
        })
      }

      if($rootScope.has_feature('base_groupon')){
        btns.push({
          img: '/images/ddt/my/groupon.png',
          label: '团购订单',
          href: '/orders/groupon'
        })
      }

      if($rootScope.has_feature('model_eat_in_hall_order')){
        btns.push({
          img: '/images/ddt/my/eat_in_hall.png',
          label: '堂食订单',
          href: '/orders/eat_in_hall'
        })
      }

      if($rootScope.has_feature('model_payment_order')){
        btns.push({
          img: '/images/ddt/my/pay.png',
          label: '闪惠买单',
          href: '/orders/payment'
        })
      }

      if($rootScope.has_feature('model_vip_info')){
        btns.push({
          img: '/images/ddt/my/recharge_record.png',
          label: '充值记录',
          href: '/orders/recharge'
        })
      }

       $scope.item_groups = btns.group();

    }])
