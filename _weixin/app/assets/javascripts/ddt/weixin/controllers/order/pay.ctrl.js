Ddt.controller('payOrderController',
  ['$rootScope', '$scope', '$routeParams', 'BaseOrderService', 'UserService', 'ShopService', 'BranchService', 'EatInHallOrderService',
  function($rootScope, $scope, $routeParams, BaseOrderService, UserService, ShopService, BranchService, EatInHallOrderService){
    $scope.branch_id = $routeParams.branch_id;
    $scope.order_type = $routeParams.order_type;
    $scope.order_id = $routeParams.order_id;
    $scope.input_pay_method = true;
    $scope.is_pay_before_mode = false;
    $scope.deduction = {};
    $scope.pay_methods = []
    $scope.self = $scope;

    UserService.get(function(user){
      $scope.user = user;
    })

    BranchService.get({id: $scope.branch_id}, function(branch){
      $scope.branch = branch;
      // pay_methods
      $scope.pay_method_setting = branch.pay_method_setting[$scope.order_type];
      var pay_methods = ShopService.get_pay_methods($scope.pay_method_setting)
      angular.forEach(pay_methods, function(pay_method){
        if(["alipay", "wechatpay", "baidupay", "vip_card_pay"].indexOf(pay_method.value)>=0){
          $scope.pay_methods.push(pay_method)
        }
      })
      $scope.item_groups = group_in($scope.pay_methods, 4);
      BaseOrderService.get($scope.order_type, $scope.branch_id, $scope.order_id, function (order) {
        $scope.order = order;
        $scope.is_pay_before_mode = $scope.branch.eat_in_hall_mode == "pay_before"
        init_coupons();
      })
    })

    $scope.get_coupon_label = function (coupon) {
      var label = coupon.name;
      if (coupon.coupon_no != null) {
        label += ' ' + coupon_no;
      }
      return label;
    };

    $scope.coupons = []
    $scope.coupons_loaded = false;

     // 添加不使用优惠券的选项
    var dont_use_option = {id: 0, name: '不使用优惠券', coupon_no: null, coupon_min_usable_amount: 0}
    function init_coupons(){
      // 添加当前使用的优惠券的选项
      if ($scope.order.coupon) {
        $scope.coupons.unshift($scope.order.coupon);
        $scope.current_coupon = $scope.order.coupon;
      }

      $scope.coupons.unshift(dont_use_option);
      if ($scope.current_coupon == null) {
        $scope.current_coupon = dont_use_option;
      }
    }



    $scope.apply_coupon = function () {
      if(parseFloat($scope.current_coupon.coupon_min_usable_amount) > parseFloat($scope.order.total)){
        $rootScope.alert("当前优惠券的最小使用金额大于订单总价 不能使用")
        return;
      }
      if($scope.current_coupon.id == 0){
        BaseOrderService.clear_coupon($scope.order_type, $scope.branch_id, $scope.order_id, function(order) {
          $scope.order = order;
        });
      }else{
        BaseOrderService.apply_coupon($scope.order_type, $scope.branch_id, $scope.order_id, $scope.current_coupon.id, function(order) {
          $scope.order = order;
        });
      }
    };

    $scope.load_coupons = function(){
      BaseOrderService.avariable_coupons($scope.order_type, $scope.branch_id, $scope.order_id, function(data) {
        $scope.coupons = data.coupons;
        $scope.coupons.unshift(dont_use_option)
        if($scope.coupons.length <= 1){
          $rootScope.alert("您当前没有满足可用条件的优惠券");
        }else{
          $scope.coupons_loaded = true;
        }
      });
    }

    $scope.deduction_credits = function(){
      var amount_for_pay = $scope.order.total;
      if(parseFloat($scope.user.credits_wallet) >= parseFloat(amount_for_pay) * $rootScope.current_shop.credits_exchange_radio){
        $scope.deduction.credits = parseFloat(amount_for_pay) * $rootScope.current_shop.credits_exchange_radio;
      }else{
        $scope.deduction.credits = parseFloat($scope.user.credits_wallet)
      }
    }

    $scope.changeCreditsDeduction =function(use_credits_deduction){
      if(use_credits_deduction){
        $scope.deduction_credits();
      }else{
        $scope.deduction.credits = undefined;
      }
    }

    $scope.change_pay_method = function (pay_method) {
      if(pay_method.value){
        if(pay_method.value === 'vip_card_pay'){
          if($scope.user.is_vip){
            $rootScope.password_modal.open(function(){
              $scope.current_pay_method = pay_method;
            })
          }else{
            $rootScope.$emit("events:receive_errors", "对不起， 您还不是会员, 如想申请会员可在用户中心下的会员卡中申请");
          }
        }else if(pay_method.value === 'wechatpay' && $scope.user.wifi_code){
          $rootScope.$emit("events:receive_errors", "对不起，wifi下单暂不支持微信支付，请选用其他支付方式");
        }else{
          $scope.current_pay_method = pay_method;
        }
      }
    }

    $scope.errors = function(){
      var errors = []
      if(!$scope.current_pay_method){ errors.push("请选择支付方式") }
      if(!(!$scope.deduction.credits || ($scope.deduction.credits > 0 && $scope.deduction.credits <= parseFloat($scope.user.credits_wallet)))){
        errors.push("积分抵扣不合法");
      }
      if(!(!$scope.deduction.card || ($scope.deduction.card > 0 && $scope.deduction.card <= parseFloat($scope.user.card_wallet)))){
        errors.push("余额抵扣不合法")
      }
      return errors;
    }

    $scope.can_submit = function(){
      return !$rootScope.is_submiting && $scope.order
             &&!!$scope.current_pay_method
             && (!$scope.deduction.credits || ($scope.deduction.credits > 0 && $scope.deduction.credits <= parseFloat($scope.user.credits_wallet)))
             && (!$scope.deduction.card || ($scope.deduction.card > 0 && $scope.deduction.card <= parseFloat($scope.user.card_wallet)))
    }

    $scope.submit = function(){
      var errors = $scope.errors();
      if (errors.length > 0) {
        $rootScope.$emit("events:receive_errors", errors);
        return;
      }

      if ($scope.can_submit()) {
        $rootScope.is_submiting = true
        var params = {
          credits_deduction: $scope.deduction.credits,
          card_deduction: $scope.deduction.card,
          pay_method: $scope.current_pay_method.value
        };
        EatInHallOrderService.update($scope.branch_id, $scope.order_id, params, function (resp) {
          $rootScope.is_submiting = false;
          if(resp.vip_pay){
            $rootScope.go('/branches/' + $scope.branch_id + '/orders/' + $scope.order_type + '/' + $scope.order_id)
          }else{
            $rootScope.go('/branches/' + $scope.branch_id + '/orders/' + $scope.order_type + '/' + $scope.order_id +'/pay_online')

          }
        })
      }
    }




  }])
