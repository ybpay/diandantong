WebposModules.add_service('base_order')
angular.module('webpos.services.base_order', []).
  factory('BaseOrderService', ['$resource','$rootScope', function($resource, $rootScope){
    var common_actions = {
      cancel:   { method: 'post', params: { action: 'cancel'}},
      confirm:  { method: 'post', params: { action: 'confirm'}},
      complete: { method: 'post', params: { action: 'complete'}},
      change_vip_info: { method: 'post', params: { action: 'change_vip_info'}},
      unbind_vip_info: { method: 'post', params: { action: 'unbind_vip_info'}},
      credits_deduction: { method: 'post', params: { action: 'credits_deduction'}},
      cancel_credits_deduction: { method: 'post', params: { action: "cancel_credits_deduction"}},
      card_deduction: { method: 'post', params: { action: 'card_deduction'}},
      privilege_discount: { method: 'post', params: { action: 'privilege_discount'}},
      privilege_reduction: { method: 'post', params: { action: 'privilege_reduction'}},
      privilege_free: { method: 'post', params: { action: 'privilege_free'}},
      moling: {method: 'post', params: {action: 'moling'}},
      cancel_privilege_discount: { method: 'post', params: { action: 'cancel_privilege_discount'}},
      cancel_privilege_reduction: { method: 'post', params: { action: 'cancel_privilege_reduction'}},
      cancel_privilege_free: { method: 'post', params: { action: 'cancel_privilege_free'}},
      cancel_moling: {method: 'post', params: {action: 'cancel_moling'}},
      apply_coupon: { method: 'post', params: { action: 'apply_coupon'}},
      clear_coupon: { method: 'post', params: { action: 'clear_coupon'}},
      rollback_coupon: { method: 'post', params: { action: 'rollback_coupon'}},
      apply_voucher: { method: 'post', params: { action: 'apply_voucher'}},
      rollback_voucher: { method: 'post', params: { action: 'rollback_voucher'}},
      bill: { method: 'get', params: { action: 'bill'}},
      create_pay_items: { method: 'post', params: { action: 'create_pay_items'}},
      clear_pay_items: { method: 'post', params: { action: 'clear_pay_items'}},
      pay_all_pay_items: { method: 'post', params: { action: 'pay_all_pay_items'}},
      add_discount_plan: { method: 'post', params: { action: 'add_discount_plan'}},
      cancel_discount_plan: { method: 'post', params: { action: 'cancel_discount_plan'}},
      add_disabled_promotion: { method: 'post', params: { action: 'add_disabled_promotion'}},
      remove_disabled_promotion: { method: 'post', params: { action: 'remove_disabled_promotion'}},
      change_weight: {method: 'post', params: {action: 'change_weight'}},
    };
    var DeliveryOrder = $resource('/branches/:branch_id/delivery_orders/:id/:action',{},
        angular.extend({
          assign_delivery_man: { method: 'post', params: { action: 'assign_delivery_man'}},
          append: { method: 'post', params: { action: 'append'}},
          active_line_items: { method: 'get', params: { action: 'active_line_items'}, isArray: true},
          subtract: { method: 'post', params: { action: 'subtract'}},
        }, common_actions));
    var EatInHallOrder = $resource('/branches/:branch_id/eat_in_hall_orders/:id/:action',{},
        angular.extend({
          change_table: { method: 'post', params: { action: 'change_table'}},
          merge_table: { method: 'post', params: { action: 'merge_table'}},
          move_itemable: { method: 'post', params: { action: 'move_itemable'}},
          append: { method: 'post', params: { action: 'append'}},
          active_line_items: { method: 'get', params: { action: 'active_line_items'}, isArray: true},
          subtract: { method: 'post', params: { action: 'subtract'}},
          bind_reservation_order: { method: 'post', params: { action: 'bind_reservation_order'}},
          anti_settlement: { method: 'post', params: { action: 'anti_settlement'}},
          trace_waiter: { method: 'post', params: {action: 'trace_waiter'}},
          update_guest_num: { method: 'post', params: { action: 'update_guest_num'}},
          hasten: { method: 'post', params: {action: 'hasten'}},
          allow_selfpay: { method: 'post', params: {action: 'allow_selfpay'}}
        }, common_actions));
    var FastfoodOrder = $resource('/branches/:branch_id/fastfood_orders/:id/:action',{},
        angular.extend({
          hasten: { method: 'post', params: { action: 'hasten'}}
        }, common_actions));
    var ReservationOrder = $resource('/branches/:branch_id/reservation_orders/:id/:action',{},
        angular.extend({
          change_to_eat_in_hall: { method: 'post', params: { action: 'change_to_eat_in_hall'}},
          bind_table: { method: 'post', params: { action: 'bind_table'}},
          edit_reservation_info: { method: 'post', params: { action: 'edit_reservation_info'}},
        }, common_actions));
    var GrouponOrder = $resource('/branches/:branch_id/groupon_orders/:id/:action',{},
        angular.extend({}, common_actions));
    var PaymentOrder = $resource('/branches/:branch_id/payment_orders/:id/:action',{},
        angular.extend({}, common_actions));
    var RechargeOrder = $resource('/branches/:branch_id/recharge_orders/:id/:action',{},
        angular.extend({
          init_refund: { method: 'post', params: { action: 'init_refund'}},
        }, common_actions));

    function get_resource(order_type){
      var resource;
      switch(order_type){
        case 'delivery':    ; resource = DeliveryOrder   ; break ;
        case 'eat_in_hall': ; resource = EatInHallOrder  ; break ;
        case 'fastfood':    ; resource = FastfoodOrder   ; break ;
        case 'reservation': ; resource = ReservationOrder; break ;
        case 'groupon':     ; resource = GrouponOrder    ; break ;
        case 'payment':     ; resource = PaymentOrder    ; break ;
        case 'recharge':    ; resource = RechargeOrder    ; break ;
      }
      return resource;
    }

    var service = {};
    angular.forEach(['get', 'confirm', 'complete',
                      'cancel_privilege_discount', 'cancel_privilege_reduction', 'cancel_privilege_free',
                      'rollback_coupon', 'rollback_voucher', 'moling', 'cancel_moling'], function(method){
      service[method] = function(order_type, branch_id, order_id, success){
        var resource = get_resource(order_type);
        resource[method]({branch_id: branch_id, id: order_id}, {}, success);
      }
    });

    function cancel(order_type, branch_id, order_id, cancel_reason, success){
      var resource = get_resource(order_type);
      resource.cancel({branch_id: branch_id, id: order_id}, {cancel_reason: cancel_reason}, success)
    }

    function pay(order_type, branch_id, order_id, params, success){
      var resource = get_resource(order_type);
      resource.pay({ branch_id: branch_id, id: order_id }, params, success)
    }

    function hasten(order_type, branch_id, order_id, params, success){
      var resource = get_resource(order_type);
      resource.hasten({branch_id: branch_id, id: order_id}, params, success)
    }

    function change_vip_info(order_type, branch_id, order_id, vip_info_id, success){
      var resource = get_resource(order_type);
      resource.change_vip_info({ branch_id: branch_id, id: order_id}, { vip_info_id: vip_info_id }, success)
    }

    function unbind_vip_info(order_type, branch_id, order_id, success){
      var resource = get_resource(order_type);
      resource.unbind_vip_info({ branch_id: branch_id, id: order_id}, {}, success)
    }

    function credits_deduction(order_type, branch_id, order_id, credits, success){
      var resource = get_resource(order_type);
      resource.credits_deduction({ branch_id: branch_id, id: order_id}, { credits: credits }, success)
    }

    function cancel_credits_deduction(order_type, branch_id, order_id, success){
      var resource = get_resource(order_type);
      resource.cancel_credits_deduction({ branch_id: branch_id, id: order_id}, {}, success)
    }

    function card_deduction(order_type, branch_id, order_id, amount, success){
      var resource = get_resource(order_type);
      resource.card_deduction({ branch_id: branch_id, id: order_id}, { amount: amount }, success)
    }

    function privilege_discount(order_type, branch_id, order_id, discount, disable_discount_amount, success){
      var resource = get_resource(order_type);
      resource.privilege_discount({ branch_id: branch_id, id: order_id}, {
        discount: discount,
        disable_discount_amount: disable_discount_amount,
        authorizer_id: $rootScope.current_authorizer_id()
       }, success)
    }

    function privilege_reduction(order_type, branch_id, order_id, reduce_amount, success){
      var resource = get_resource(order_type);
      resource.privilege_reduction({branch_id: branch_id, id: order_id}, { reduce_amount: reduce_amount,
        authorizer_id: $rootScope.current_authorizer_id()
      }, success )
    }

    function privilege_free(order_type, branch_id, order_id, success){
      var resource = get_resource(order_type);
      resource.privilege_free({ branch_id: branch_id, id: order_id}, {
        authorizer_id: $rootScope.current_authorizer_id()
      }, success)
    }

    function apply_coupon(order_type, branch_id, order_id, coupon_id, success){
      var resource = get_resource(order_type);
      resource.apply_coupon({ branch_id: branch_id, id: order_id}, { coupon_id: coupon_id}, success)
    }

    function apply_voucher(order_type, branch_id, order_id, voucher_id, success){
      var resource = get_resource(order_type);
      resource.apply_voucher({ branch_id: branch_id, id: order_id}, { voucher_id: voucher_id}, success)
    }

    function bill(order_type, branch_id, order_id, bill_type, options, success){
      var resource = get_resource(order_type)
      return resource.bill({branch_id: branch_id, id: order_id, bill_type: bill_type, options: options}).$promise.then(success)
    }

    function append(order_type, branch_id, order_id, params, success){
      var resource = get_resource(order_type)
      resource.append({ branch_id: branch_id, id: order_id}, {
        itemables: params.itemables,
        note: params.note,
        is_local_printed: params.is_local_printed
      }, success)
    }

    function active_line_items(order_type, branch_id, order_id, success) {
      var resource = get_resource(order_type)
      resource.active_line_items({branch_id: branch_id, id: order_id}, success);
    }

    function subtract(order_type, branch_id, order_id, subtractables, success) {
      var resource = get_resource(order_type)
      resource.subtract({branch_id: branch_id, id: order_id}, {
        subtractables: subtractables
      }, success);
    }

    function create_pay_items(order_type, branch_id, order_id, pay_items, success){
      var resource = get_resource(order_type)
      resource.create_pay_items({branch_id: branch_id, id: order_id}, {
        pay_items: pay_items,
        is_local_printed: $rootScope.local_printer_configed()
      }, success);
    }

    function clear_pay_items(order_type, branch_id, order_id, success){
      var resource = get_resource(order_type)
      resource.clear_pay_items({branch_id: branch_id, id: order_id}, {}, success);
    }

    function pay_all_pay_items(order_type, branch_id, order_id, success){
      var resource = get_resource(order_type)
      resource.pay_all_pay_items({branch_id: branch_id, id: order_id}, {
        is_local_printed: $rootScope.local_printer_configed(),
        bill_type: $rootScope.order_bill_type()
      }, success);
    }

    function add_discount_plan(order_type, branch_id, order_id, discount_plan_id, success){
      var resource = get_resource(order_type)
      resource.add_discount_plan({branch_id: branch_id, id: order_id}, {discount_plan_id: discount_plan_id}, success);
    }

    function cancel_discount_plan(order_type, branch_id, order_id, success){
      var resource = get_resource(order_type)
      resource.cancel_discount_plan({branch_id: branch_id, id: order_id}, {}, success);
    }

    function add_disabled_promotion(order_type, branch_id, order_id, promotion_id, success){
      var resource = get_resource(order_type)
      resource.add_disabled_promotion({branch_id: branch_id, id: order_id}, {promotion_id: promotion_id}, success);
    }

    function remove_disabled_promotion(order_type, branch_id, order_id, promotion_id, success){
      var resource = get_resource(order_type)
      resource.remove_disabled_promotion({branch_id: branch_id, id: order_id}, {promotion_id: promotion_id}, success);
    }

    return angular.extend(service, {
      get_resource: get_resource,
      cancel: cancel,
      hasten: hasten,
      change_vip_info: change_vip_info,
      unbind_vip_info: unbind_vip_info,
      credits_deduction: credits_deduction,
      cancel_credits_deduction: cancel_credits_deduction,
      card_deduction: card_deduction,
      privilege_discount:privilege_discount,
      privilege_reduction: privilege_reduction,
      privilege_free: privilege_free,
      apply_coupon: apply_coupon,
      apply_voucher: apply_voucher,
      bill: bill,
      append: append,
      active_line_items: active_line_items,
      subtract: subtract,
      create_pay_items: create_pay_items,
      clear_pay_items: clear_pay_items,
      pay_all_pay_items: pay_all_pay_items,
      add_discount_plan: add_discount_plan,
      cancel_discount_plan: cancel_discount_plan,
      add_disabled_promotion: add_disabled_promotion,
      remove_disabled_promotion: remove_disabled_promotion
    });
  }])
