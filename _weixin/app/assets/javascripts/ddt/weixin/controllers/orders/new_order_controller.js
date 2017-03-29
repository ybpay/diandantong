Ddt.controller('newDeliveryOrderController', [
    '$rootScope', '$scope', '$location', '$timeout', 'BaseNewOrderController', 'AddressService', 'DeliveryCartService', 'DeliveryOrderService', 'UserService', '$routeParams',
    function ($rootScope, $scope, $location, $timeout, BaseNewOrderController, AddressService, DeliveryCartService, DeliveryOrderService, UserService, $routeParams) {
      $rootScope.title = '外卖订单';
      $scope.cart_type = 'delivery';

      BaseNewOrderController.action($scope, function() {
        $scope.note = "";
        $scope.addresses = [];
        $scope.current_address = null;
        $scope.delivery_zones = $scope.branch.delivery_zones;
        $scope.delivery_dates = $scope.branch.delivery_dates;
        $scope.delivery_times = [];
        $scope.current_delivery_zone = null;
        $scope.current_delivery_time = null;
        $scope.current_delivery_date = null;
        $scope.need_location = false;

        $scope.current_delivery_zone_id = function(){
          if($scope.current_delivery_zone){ return $scope.current_delivery_zone.id }
        }

        $scope.current_delivery_date_str = function () {
          if ($scope.current_delivery_date) {
            return $scope.current_delivery_date.date;
          }
        }
        $scope.current_delivery_time_id = function(){
          if($scope.current_delivery_time){ return $scope.current_delivery_time.id }
        }

        $scope.update_shipment = function () {
          DeliveryCartService.update_shipment($scope.branch_id, {
            address_id: $scope.current_address.id,
            delivery_zone_id: $scope.current_delivery_zone_id(),
            delivery_time_id: $scope.current_delivery_time_id(),
            delivery_date: $scope.current_delivery_date_str()
          }, function (cart) {
            $scope.cart = cart;
          });
        };

        $scope.current_user_is_blocked = $scope.user.is_blocked;
        if ($scope.current_user_is_blocked) {
          $rootScope.$emit("events:receive_errors", ['您已被商家禁止下单！']);
        };
        $scope.current_address = $scope.user.default_address;

        // 当前选择的地址是否需要定位，暂时只对按距离收取外送费的客户进行试用
        // 国内用户不进行地址定位
        if($scope.enable_foreign && $scope.current_address){
          $scope.need_location = $scope.branch.is_charge_by_distance && ($scope.current_address.longitude == null || $scope.current_address.latitude == null)
        }

        if($scope.need_location==false){
          if($scope.current_address && $scope.current_address.id != $scope.cart.shipment.address_id){
            $scope.update_shipment();
          }
        }

        if (!$scope.current_address) {
          AddressService.store_url($location.path());
          $location.path("/addresses/new");
          return;
        }



        $scope.errors = function(){
          if($scope.current_user_is_blocked){ return ['您已被商家禁止下单！']}
          var form_contents_errors = $scope.is_form_contents_valid();
          var distance_errors = $scope.is_distance_of_branch_to_address_valid($scope.current_address);
          var base_errors = $scope.base_errors();

          return $scope.flatten_errors([form_contents_errors, distance_errors, base_errors, other_errors()]);
        }

        var other_errors = function(){
          var errors = [];
          if(!$scope.branch.is_in_service){ errors.push("该门店还未营业")}
          if(!$scope.cart_not_empty()){errors.push("您还未选择产品")}
          if(!($scope.cart && parseFloat($scope.cart.item_total) >= parseFloat($scope.branch.support_delivery_if_amount_gt))){
            errors.push("最低 " + $scope.currency + $scope.branch.support_delivery_if_amount_gt +" 起送");
          }
          return errors;
        }

        //=== order
        $scope.can_submit = function () {
          var condition_list = [
            $scope.base_can_submit(),
            $scope.branch.is_in_service,
            $scope.current_address,
            $scope.cart_not_empty(),
            $scope.cart && parseFloat($scope.cart.item_total) >= parseFloat($scope.branch.support_delivery_if_amount_gt),
            !$scope.current_user_is_blocked
          ];

          var result = condition_list.reduce(function (acc, elem) {
            return acc && elem;
          });
          return result;
        };

        $scope.submit = function () {
          var errors = $scope.errors();
          if (errors.length > 0) {
            $rootScope.$emit("events:receive_errors", errors);
            return;
          }

          if ($scope.can_submit()) {
            $rootScope.is_submiting = true
            DeliveryOrderService.create($scope.branch_id, {
              shipment: {
                address_id:       $scope.current_address.id,
                delivery_zone_id: $scope.current_delivery_zone_id(),
                delivery_time_id: $scope.current_delivery_time_id(),
                delivery_date:    $scope.current_delivery_date_str()
              },
              note: $scope.note,
              pay_method: $scope.current_pay_method.value,
              credits_deduction: $scope.deduction.credits,
              card_deduction: $scope.deduction.card,
              form_contents: $scope.form_contents()
            }, function (resp) {
              $rootScope.is_submiting = false
              $rootScope.go('/branches/' + $scope.branch_id + '/order_success/'+ resp.order.id + '/delivery', false);
            });
          }
        };

        $scope.cart_not_empty = function(){
          return $scope.cart && $scope.cart.item_count > 0
        }

        $scope.change_address = function () {
          AddressService.store_url($location.path());
          $location.path("/addresses");
        };

        //=== delivery_zones
        if(!$scope.branch.is_charge_by_distance){
          angular.forEach($scope.delivery_zones, function (delivery_zone) {
            if (delivery_zone.id == $scope.cart.shipment.delivery_zone_id) {
              $scope.current_delivery_zone = delivery_zone
            }
          })
          if($scope.delivery_zones.length>0 && !$scope.current_delivery_zone){
            $scope.current_delivery_zone = $scope.delivery_zones[0];
          }
        }

        $scope.can_select_delivery_zone = function(){
          return !$scope.branch.is_charge_by_distance && $scope.delivery_zones.length > 0
        }

        $scope.change_delivery_zone = function(){
          //if(!$scope.branch.is_charge_by_distance){
            $scope.update_shipment();
          //}
        }



        //=== delivery_times
        var set_delivery_times = function(delivery_times){
          $scope.delivery_times = delivery_times;
          var current_delivery_time = null;
          angular.forEach(delivery_times, function (delivery_time){
            if (delivery_time.id == $scope.cart.shipment.delivery_time_id){
              current_delivery_time = delivery_time;
            }
          })
          $scope.current_delivery_time = current_delivery_time || delivery_times[0]
        }

        $scope.change_delivery_time = function(){
          $scope.update_shipment();
        }

        //=== delivery_dates
        var set_current_delivery_date = function(delivery_date){
          $scope.current_delivery_date = delivery_date
          set_delivery_times($scope.current_delivery_date.delivery_times);
        }
        var date_found = false;
        angular.forEach($scope.delivery_dates, function (delivery_date) {
          if (delivery_date.date == $scope.cart.shipment.delivery_date){
            date_found = true;
            set_current_delivery_date(delivery_date)
          }
        });

        if(!date_found && $scope.delivery_dates.length > 0){
          set_current_delivery_date($scope.delivery_dates[0])
        }

        $scope.change_delivery_date = function(){
          set_delivery_times($scope.current_delivery_date.delivery_times)
        }

        //-----------------

        $scope.location = function(){
          AddressService.store_url($location.path());
          $rootScope.go("/addresses/" + $scope.current_address.id + "/chose_location", false);
        }

        BaseNewOrderController.use_coupon_setting($scope, $scope.cart_type);

      });

    }]).factory('newOrderInHallController', ['$rootScope', 'BaseNewOrderController','EatInHallOrderService',
    function ($rootScope, BaseNewOrderController, EatInHallOrderService){

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
            $rootScope.go('/branches/' + $scope.branch_id + '/order_success/'+ resp.order.id + '/'+order_type, false);
          })
        }
      }


    }

    return {
      action: action
    }

  }]).controller('newFastfoodOrderController', ['$rootScope', '$scope', '$timeout', 'BaseNewOrderController', 'newOrderInHallController', 'FastfoodOrderService',
  function ($rootScope, $scope, $timeout, BaseNewOrderController, newOrderInHallController, FastfoodOrderService){
    $rootScope.title = '快餐订单';
    $scope.cart_type = 'fastfood'
    $scope.service = FastfoodOrderService

    newOrderInHallController.action($scope, function(){})

    $scope.other_errors = function(){
      var errors = []
      if(!$scope.cart_not_empty()){ errors.push("您还未选择产品")}
      return errors;
    }

    $scope.can_submit = function(){
      return $scope.base_can_submit() && $scope.cart_not_empty()
    }

    $scope.submit = function(){
      if($scope.current_pay_method){
        $scope.common_submit({pay_method: $scope.current_pay_method.value}, 'fastfood');
      }else{
        $scope.common_submit({}, 'fastfood');
      }

    }


  }]).controller('newEatInHallOrderController', [
    '$rootScope', '$scope', '$timeout', 'BaseNewOrderController','newOrderInHallController', 'EatInHallOrderService', 'GeolocationService',
    function ($rootScope, $scope, $timeout, BaseNewOrderController, newOrderInHallController, EatInHallOrderService, GeolocationService) {
      $rootScope.title = '堂点订单';
      $scope.cart_type = 'eat_in_hall'
      $scope.service = EatInHallOrderService;
      $scope.is_pay_before_mode = false;

      newOrderInHallController.action($scope, function(){
        $scope.is_pay_before_mode = $scope.branch.eat_in_hall_mode == "pay_before"
        if(!$scope.is_pay_before_mode){
          $scope.input_pay_method = false;
        }
        if($scope.cart && $scope.cart.ban_selfpay){
          $scope.pay_methods = $scope.pay_methods.filter(function(pay_method){ return pay_method.value != 'vip_card_pay'});
        }
      })

      var guest_num_invalid = function(){
        return $scope.cart && ($scope.cart.guest_num==null || $scope.cart.guest_num == "")
      }

      $scope.other_errors = function(){
        var errors = []
        if(!$scope.cart_not_empty()){ errors.push("您还未选择产品")}
        if(guest_num_invalid()){ errors.push("请填写就餐人数")}
        return errors;
      }

      $scope.can_submit = function () {
        return $scope.base_can_submit() && $scope.cart_not_empty() && !guest_num_invalid();
      }

      $scope.submit = function () {

        var do_submit = function(){
          var ext_params = {guest_num: parseInt($scope.cart.guest_num)}
          if($scope.is_pay_before_mode && $scope.current_pay_method){
            ext_params.pay_method = $scope.current_pay_method.value
          }
          $scope.common_submit(ext_params,  'eat_in_hall');
        }

        if ($scope.branch.enable_user_location_limitation){
          GeolocationService.distance(
            {
              latitude: $scope.branch.latitude,
              longitude: $scope.branch.longitude
            }, function (dist) {
              console.info(dist);
              if (dist < 300) {
                do_submit()
              }else{
                $rootScope.alert("请到餐厅扫码下单")
              }
            }, function (status) {
              $rootScope.alert("无法获取地理位置信息,请检查地理位置授权设置")
            }
          );
        } else {
          do_submit()
        }
      }

    }]).controller('newReservationOrderController', [
    '$rootScope', '$scope', '$location', '$timeout', 'BaseNewOrderController', 'ReservationOrderService', 'AddressService', 'UserService',
    function ($rootScope, $scope, $location, $timeout, BaseNewOrderController, ReservationOrderService, AddressService, UserService) {
      $rootScope.title = '预订订单';
      $scope.cart_type = 'reservation'

      BaseNewOrderController.action($scope, function () {
        if (!$scope.cart.reservation_date_str || !$scope.cart.reservation_time_point_str) {
          $rootScope.clear_history_url()
          $rootScope.go("/branches/" + $scope.branch_id + '/reservation_time_points')
        }

        var support_prepayment_type = $scope.branch.reservation_setting.prepayment_type;
        if (support_prepayment_type == 'only_table') {
          // $scope.prepayment_type = 'prepay_for_table';
          $scope.show_for_table = true;
        } else if (support_prepayment_type == 'only_order') {
          // $scope.prepayment_type = 'prepay_for_order';
          $scope.show_for_order = true;
          if ($scope.cart.item_count > 0) {
            $scope.prepayment_type = 'prepay_for_order';
          }
        } else { // support_prepayment_type == 'table_or_order'
          // 在订座和提前点餐都支持的情况下，如果购物车里有产品，则将预付类型设为提前点餐。
          if ($scope.cart.item_count > 0) {
            $scope.prepayment_type = 'prepay_for_order';
          }
          $scope.show_for_table = true;
          $scope.show_for_order = true;
        }
      })

      $scope.note = null

      $scope.prepay_total = function () {
        if ($scope.prepayment_type == 'prepay_for_table') {
          return $scope.cart.table_zone.reservation_price
        } else if ($scope.prepayment_type == 'prepay_for_order') {
          return $scope.cart.total
        }
      }

      $scope.errors = function(){
        var form_contents_errors = $scope.is_form_contents_valid();
        var base_errors = $scope.base_errors();
        return $scope.flatten_errors([form_contents_errors, base_errors, other_errors()]);
      }

      var other_errors = function(){
        var errors = []
        if(!$scope.prepayment_type){
          errors.push("请选择预订操作的类型")
        }
        if($scope.prepayment_type == "prepay_for_order" && parseFloat($scope.cart.total) < parseFloat($scope.cart.table_zone.min_reservation_price) ){
          errors.push("不得低于起定价： " + $scope.currency + $scope.cart.table_zone.min_reservation_price)
        }
        if($scope.cart.reservation_time_point_str == null || $scope.user.reservation_time_point_str == ""){errors.push("预订时间非法，请重新选择")}
        if($scope.user.reservation_gender == null || $scope.user.reservation_gender == ""){ errors.push("请选择性别") }
        if($scope.user.reservation_name == null || $scope.user.reservation_name == ""){ errors.push("请填写您的姓名") }
        if($scope.user.reservation_phone == null || $scope.user.reservation_phone == ""){ errors.push("请填写您的联系电话") }
        return errors;
      }

      $scope.can_submit = function () {
        if($scope.base_can_submit()){
          if ($scope.prepayment_type == 'prepay_for_table') {
            return true;
          } else if ($scope.prepayment_type == 'prepay_for_order') {
            return parseFloat($scope.cart.total) >= parseFloat($scope.cart.table_zone.min_reservation_price)
          }
          else{
            return false
          }
        }else{
          return false
        }
      }

      $scope.submit = function () {
        var errors = $scope.errors();
        if (errors.length > 0) {
          $rootScope.$emit("events:receive_errors", errors);
          return;
        }

        if ($scope.can_submit()) {
          $rootScope.is_submiting = true
          ReservationOrderService.create($scope.branch_id, {
            note: $scope.note,
            name: $scope.user.reservation_name,
            phone: $scope.user.reservation_phone,
            gender: $scope.user.reservation_gender,
            prepayment_type: $scope.prepayment_type,
            pay_method: $scope.current_pay_method.value,
            credits_deduction: $scope.deduction.credits,
            card_deduction: $scope.deduction.card,
            form_contents: $scope.form_contents()
          }, function (resp) {
            $rootScope.is_submiting = false
            $rootScope.go('/branches/' + $scope.branch_id + '/order_success/'+ resp.order.id + '/reservation', false);
          })
        }
      }

      $scope.go_to_reservation_products = function() {
        UserService.set($scope.user)
        $rootScope.go('/branches/' + $scope.branch_id + '/products/reservation');
      };

    }]).controller('newGrouponOrderController', [
    '$rootScope', '$scope', '$timeout', 'BaseNewOrderController', 'GrouponOrderService',
    function ($rootScope, $scope, $timeout, BaseNewOrderController, GrouponOrderService) {
      $rootScope.title = '团购订单';
      $scope.cart_type = 'groupon'
      BaseNewOrderController.action($scope, function () {})

      $scope.errors = function(){
        var base_errors = $scope.base_errors();
        return $scope.flatten_errors([base_errors, other_errors()]);
      }

      var other_errors = function(){
        var errors = []
        if(!$scope.cart_not_empty()){ errors.push("您还未选择产品")}
        return errors;
      }

      $scope.can_submit = function () {
        return $scope.base_can_submit() && $scope.cart_not_empty();
      }

      $scope.submit = function () {

        var errors = $scope.errors();
        if (errors.length > 0) {
          $rootScope.$emit("events:receive_errors", errors);
          return;
        }

        if ($scope.can_submit()) {
          $rootScope.is_submiting = true
          GrouponOrderService.create($scope.branch_id, {
            note: $scope.note,
            pay_method: $scope.current_pay_method.value,
            credits_deduction: $scope.deduction.credits,
            card_deduction: $scope.deduction.card
          }, function (resp) {
            $rootScope.is_submiting = false
            $rootScope.go('/branches/' + $scope.branch_id + '/order_success/'+ resp.order.id + '/groupon', false);
          })
        }
      }
    }]).controller('newRechargeOrderController', [
    '$rootScope', '$scope', '$timeout', 'BaseNewOrderController', 'UserService', 'RechargeOrderService','RechargeProductService','RechargeCartService',
    function ($rootScope, $scope, $timeout, BaseNewOrderController, UserService, RechargeOrderService, RechargeProductService,RechargeCartService) {
      $rootScope.title = $rootScope.current_shop.name;
      $scope.cart_type = 'recharge'
      BaseNewOrderController.action($scope, function () {})

      RechargeProductService.query(function(recharge_products) {
        $scope.recharge_products = recharge_products
      });

      UserService.get(function(user){
        if(!user.is_vip){
          $rootScope.alert("您还不是会员")
          $rootScope.back()
        }
      });

      $scope.errors = function(){
        var base_errors = $scope.base_errors();
        return $scope.flatten_errors([base_errors, other_errors()]);
      }

      var other_errors = function(){
        var errors = []
        if(!$scope.cart_not_empty()){ errors.push("您还未选择产品")}
        return errors;
      }

      $scope.can_submit = function () {
        return $scope.base_can_submit() && $scope.cart_not_empty()
      }

      $scope.change_recharge_product = function(recharge_product ){
        RechargeCartService.add_recharge_product($rootScope.current_shop.abstract_branch_id, recharge_product.id, function(cart){
          $scope.cart = cart
        })
      }

      $scope.is_active = function(recharge_product){
        return $scope.cart && $scope.cart.line_items[0] && $scope.cart.line_items[0].itemable_id == recharge_product.id
      }

      $scope.submit = function () {

        var errors = $scope.errors();
        if (errors.length > 0) {
          $rootScope.$emit("events:receive_errors", errors);
          return;
        }

        if ($scope.can_submit()) {
          $rootScope.is_submiting = true
          RechargeOrderService.create($scope.branch_id, {
            note: $scope.note,
            pay_method: $scope.current_pay_method.value,
            credits_deduction: $scope.deduction.credits,
            card_deduction: $scope.deduction.card
          }, function (resp) {
            $rootScope.is_submiting = false
            $rootScope.go('/branches/' + $scope.branch_id + '/orders/recharge/'+ resp.order.id + '?pay_online=true', false);
          })
        }
      }
    }])
