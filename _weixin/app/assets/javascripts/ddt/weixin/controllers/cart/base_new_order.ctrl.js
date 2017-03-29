Ddt.factory('BaseNewOrderController', [
    '$rootScope', '$routeParams', 'BaseCartService', 'BranchService', 'CartAction',
    'SnapCartService', 'ShopService', 'UserService', 'BaseOrderService', 'GeolocationService',
    function ($rootScope, $routeParams, BaseCartService, BranchService, CartAction,
      SnapCartService, ShopService, UserService, BaseOrderService, GeolocationService) {
      function action($scope, callback) {
        $scope.branch_id = $routeParams.branch_id
        $scope.branch = null
        $scope.cart = null
        $scope.pay_method_setting = {}
        $scope.pay_methods = []
        $scope.current_pay_method = null
        $scope.user = null
        $scope.deduction = {}
        $scope.input_pay_method = true;

        CartAction.action($scope)

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
            }else{
              $scope.current_pay_method = pay_method;
            }
          }
        }

        $scope.cart_not_empty = function(){
          return $scope.cart && (parseFloat($scope.cart.total) > 0 || $scope.cart.item_count > 0)
        }

        $scope.base_errors = function(){
          var errors = []
          if($scope.input_pay_method && !$scope.current_pay_method){ errors.push("请选择支付方式") }
          if($scope.input_pay_method && !(!$scope.deduction.credits || ($scope.deduction.credits > 0 && $scope.deduction.credits <= parseFloat($scope.user.credits_wallet)))){
            errors.push("积分抵扣不合法");
          }
          if(!(!$scope.deduction.card || ($scope.deduction.card > 0 && $scope.deduction.card <= parseFloat($scope.user.card_wallet)))){
            errors.push("余额抵扣不合法")
          }
          return errors;
        }

        $scope.base_can_submit = function(){
          var base_condition = !$rootScope.is_submiting && (!$scope.deduction.credits || ($scope.deduction.credits > 0 && $scope.deduction.credits <= parseFloat($scope.user.credits_wallet))) && (!$scope.deduction.card || ($scope.deduction.card > 0 && $scope.deduction.card <= parseFloat($scope.user.card_wallet)))
          if($scope.input_pay_method){
            return base_condition && $scope.current_pay_method
          }else{
            return base_condition
          }
        }

        // 调用回调前须完成的xhr 任务数
        var must_finish_xhr_task = 1
        // xhr 完成后尝试调用回调函数
        var try_callback = function(){
          if(--must_finish_xhr_task == 0){
            if(callback){ callback() }
          }
        }

        UserService.get(function(user){
          $scope.user = user
          if($scope.user.reservation_phone){
            $scope.user.reservation_phone  = parseInt($scope.user.reservation_phone)
          }
        })

        ShopService.get(function(shop){
          $scope.enable_foreign = shop.enable_foreign;
        });

        BranchService.get({id: $scope.branch_id}, function (branch) {
          $scope.branch = branch;
          // pay_methods
          $scope.pay_method_setting = branch.pay_method_setting[$scope.cart_type];
          $scope.pay_methods = ShopService.get_pay_methods($scope.pay_method_setting)
          $scope.item_groups = group_in($scope.pay_methods, 4);
          // 取消默认选项
          // $scope.current_pay_method = $scope.pay_methods[0]

          $scope.form_elements = $scope.branch.form_elements.filter(function(element) {
            return element.support_order_types.indexOf($scope.cart_type) != -1;
          });

          BaseCartService.get_cache_cart($scope.cart_type, $scope.branch_id, function(cart){
            $scope.cart = cart
            try_callback();
          })

          GeolocationService.distance($scope.branch, function(distance){
            $scope.branch.distance = distance
          });
        })

        $rootScope.$on("cart:change", function (e, cart) {
          $scope.cart = cart
          SnapCartService.set_cart($scope.cart_type, $scope.branch_id, cart)
        })

        $scope.form_contents = function() {
          var form_records = [];
          $.each($scope.form_elements, function() {
            form_records.push(this["record"]);
          });

          return form_records;
        };


        $scope.is_form_contents_valid = function() {
          var errors = [];
          angular.forEach($scope.form_elements, function(form_element) {
            if (typeof(form_element.record.content) == 'undefined') {
              form_element.record.content = '';
            }
            var content = $.trim(form_element.record.content);

            if(form_element.need && content === '') {
              errors.push(form_element.label + "不能为空");
            }
          });

          return errors;
        };

        $scope.flatten_errors = function(error_collection_array){
          var errors = []
          angular.forEach(error_collection_array, function(error_collection){
            angular.forEach(error_collection, function(error){
              errors.push(error);
            });
          });
          return errors;
        }

        $scope.deduction_credits = function(){
          var amount_for_pay = get_amount_for_pay();
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

        $scope.deduction_password_authenticate = function(){
          $rootScope.password_modal.open(function(){

              var amount_for_pay = get_amount_for_pay();
              if( parseFloat($scope.user.card_wallet) >= parseFloat(amount_for_pay)){
                $scope.deduction.card = parseFloat(amount_for_pay)
              }else{
                $scope.deduction.card = parseFloat(user_amount)
              }
          })
        }

        function get_amount_for_pay(){
          var amount_for_pay = $scope.cart.total
          if($scope.cart_type == 'reservation'){
            amount_for_pay = parseFloat($scope.cart.total) * $scope.cart.table_zone.reservation_price_percent / 100
          }
          return amount_for_pay;
        }
      }

      // 执行优惠券相关代码。只能在BaseNewOrderController.action中执行。
      var use_coupon_setting = function($scope, cart_type) {
        $scope.coupons_loaded = false;
        $scope.coupons = [];


        // 添加当前使用的优惠券的选项
        if ($scope.cart.coupon) {
          $scope.coupons.unshift($scope.cart.coupon);
          $scope.current_coupon = $scope.cart.coupon;
        }
        // 添加不使用优惠券的选项
        var dont_use_option = {id: 0, name: '不使用优惠券', coupon_no: null, coupon_min_usable_amount: 0}
        $scope.coupons.unshift(dont_use_option);
        if ($scope.current_coupon == null) {
          $scope.current_coupon = dont_use_option;
        }

        $scope.apply_coupon = function () {
          if($scope.current_coupon.id == 0){
            BaseCartService.clear_coupon(cart_type, $scope.branch_id, function(cart) {
              $scope.cart = cart;
            });
          }else{
            BaseCartService.apply_coupon(cart_type, $scope.branch_id, $scope.current_coupon.id, function(cart){
              $scope.cart = cart;
            })
          }
        };

        $scope.get_coupon_label = function (coupon) {
          var label = coupon.name;
          if (coupon.coupon_no != null) {
            label += ' ' + coupon_no;
          }
          return label;
        };

        $scope.load_coupons = function(){
          BaseOrderService.association_domains(cart_type, $routeParams.branch_id, function(data) {
            $scope.coupons = data.coupons
            $scope.coupons.unshift(dont_use_option)
            if($scope.coupons.length <= 1){
              $rootScope.alert("您当前没有满足可用条件的优惠券");
            }else{
              $scope.coupons_loaded = true;
            }
          });
        }
      };

      return {
        use_coupon_setting: use_coupon_setting,
        action: action
      };
    }]).factory('newOrderInHallController', ['$location', '$rootScope', 'BaseNewOrderController','EatInHallOrderService', 'SnapCartService',
    function ($location, $rootScope, BaseNewOrderController, EatInHallOrderService, SnapCartService){

    function action($scope, callback){
      BaseNewOrderController.action($scope, function () {
        if($scope.service == EatInHallOrderService){
          if (!$scope.cart.table_id) {
            $rootScope.clear_history_url()
            $rootScope.go("/branches/" + $scope.branch_id)
          }
        }
        BaseNewOrderController.use_coupon_setting($scope, $scope.cart_type);
        callback();
      })

      $scope.errors = function(){
        var form_contents_errors = $scope.is_form_contents_valid();
        var base_errors = $scope.base_errors();
        return $scope.flatten_errors([form_contents_errors, base_errors, $scope.other_errors()]);
      }

      $scope.common_submit = function(ext_params, order_type){
        var errors = $scope.errors();
        if (errors.length > 0) {
          $rootScope.$emit("events:receive_errors", errors);
          return;
        }

        if ($scope.can_submit()) {
          $rootScope.is_submiting = true
          var params = {
            note: $scope.note,
            credits_deduction: $scope.deduction.credits,
            card_deduction: $scope.deduction.card,
            form_contents: $scope.form_contents()
          };
          $.extend(params, ext_params);
          $scope.service.create($scope.branch_id, params, function (resp) {
            $rootScope.is_submiting = false
            SnapCartService.set_cart(order_type, $scope.branch_id, null)
            $rootScope.go('/branches/' + $scope.branch_id + '/order_success/'+ resp.order.id + '/'+order_type)
          })
        }
      }


    }

    return {
      action: action
    }

  }])
