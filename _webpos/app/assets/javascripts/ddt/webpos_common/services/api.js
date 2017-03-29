WebposModules.add_service('api');
var Api = angular.module('webpos.services.api', []);
Api.factory("Shop", ["$resource", function($resource){
  return $resource("/", {}, {})
}])
Api.factory('Branch', ['$resource',function($resource){
  return $resource('/branches/:id/:action', {},{
        query: { method: 'get', isArray: true, cache: true },
        get: { method: 'get', cache: true },
        open_shift: { method: 'post', params: { action: 'open_shift'}},
        close_shift: { method: 'post', params: { action: 'close_shift'}},
        get_shift: { method: 'get', params: { action: 'get_shift'}},
        print_shift: { method: 'post', params: { action: 'print_shift'}},
        sdu_upload_orders: { method: 'post', params: { action: 'sdu_upload_orders'}},
        sdu_query_orders: { method: 'post', params: { action: 'sdu_query_orders'}},
        get_waiter_names: { method: 'get', isArray: true, cache: true, params: { action: 'waiter_names'}},
        cache_versions: { method: 'get', params: {action: 'cache_versions'}}
      });
}]);
Api.factory('Category', ['$resource',function($resource){
  return $resource('/branches/:branch_id/categories/:id/:action',{},{
      query: { method: 'get', isArray: true, cache: true }
    })
}]);
Api.factory('Litp', ['$resource',function($resource){
  return $resource("/branches/:branch_id/litps/:id/:action",{},{
      query: { method: "get", isArray: true },
      counts: { method: "get", params: {action: "counts"} },
      cooks: { method: "get", params: {action: "cooks"}, isArray: true },
      confirm: { method: "put", params: {action: "confirm"}},
      complete: { method: "put", params: {action: "complete"}},
    });
}]);
Api.factory('Table', ['$resource',function($resource){
  return $resource('/branches/:branch_id/tables/:id/:action', {},{
      open: { method: 'post', params: { action: 'open'}},
      get_changed_tables: { method: 'get', params: { action: 'get_changed_tables'}, isArray: true },
      get_reservation_tables: { method: 'get', params: { action: 'get_reservation_tables'}, isArray: true},
      update_guest_num: { method: 'post', params: {action: 'update_guest_num'}},
      clear: { method: 'post', params: { action: 'clear'}},
      check_out: { method: 'post', params: { action: 'check_out'}},
      cancel_check_out: { method: 'post', params: { action: 'cancel_check_out'}},
      force_clear: { method: 'post', params: { action: 'force_clear'}},
    });
}]);
Api.factory('Product', ['$resource',function($resource){
  return $resource('/branches/:branch_id/products/:id/:action',{},{
    query: { method: 'get', isArray: true }
  })
}]);
Api.factory('VipInfo', ['$resource',function($resource){
  return $resource('/vip_infos/:id/:action',{},{
    merge: { method: 'post', params: { action: 'merge'}},
    become: { method: 'post', params: { action: 'become'}},
    reject:{ method: 'post', params: { action: 'reject'}},
    update:{ method: 'post'},
    get_by_scan_code: { method: 'get', params: { action: 'get_by_scan_code'}},
    wallet_logs: {method: 'get', params: {action: 'wallet_logs'}, isArray: true}
  })
}]);
Api.factory('CreditsWallet', ['$resource',function($resource){
  return $resource('/user_credits_wallets/:id/:action',{},{
    exchange: {method: 'post', params: {action: 'exchange'}},
    get: {method: 'post', params: {action: 'get'}}
  })
}]);
Api.factory('VipLevel', ['$resource',function($resource){
  return $resource('/vip_levels',{},{
    query: { method: 'get', isArray: true, cache: true }
  })
}]);
Api.factory('RechargeProduct', ['$resource',function($resource){
  return $resource('/recharge_products/:id/:action', {},{
        query:  { method: 'get', isArray: true, cache: true}
      });
}]);
Api.factory('BillCenter', ['$resource',function($resource){
  return $resource('/branches/:branch_id/bill_center/:action', {},{
        discount_list:        { method: 'get', params: { action: 'discount_list'}},
        gift_item_list:       { method: 'get', params: { action: 'gift_item_list'}},
        subtract_item_list:   { method: 'get', params: { action: 'subtract_item_list'}},
        sale_list:            { method: 'get', params: { action: 'sale_list'}},
        payment_list:         { method: 'get', params: { action: 'payment_list'}},
        shift_list:           { method: 'get', params: { action: 'shift_list'}},
        combo_package_list:   { method: 'get', params: { action: 'combo_package_list'}},
        anti_settlement_list: { method: 'get', params: { action: 'anti_settlement_list'}},
        order_cancel_list:    { method: 'get', params: { action: 'order_cancel_list'}},
        waiter_list:          { method: 'get', params: { action: 'waiter_list'}},
        queue_list:           { method: 'get', params: { action: 'queue_list'}},
        by_weight_product_list: { method: 'get', params: { action: 'by_weight_product_list'}},
      });
}]);

Api.factory('QueueSetting', ['$resource',function($resource){
  return $resource('/branches/:branch_id/queue_settings/:id/:action',{},{
      query: { method: 'get', isArray: true, cache: true},
      history: { method: 'get', isArray: true, params: { action: 'history'}},
      queue_states: { method: 'get', isArray: true, params: {action: 'queue_states'}},
      create_guest_queue: { method: 'post', params: {action: 'create_guest_queue'}},
      set_notify_number_in_advance: {method: 'post', isArray: true, params: {action: 'set_notify_number_in_advance'}}
    })
}]);
Api.factory('GuestQueue', ['$resource',function($resource){
  return $resource('/branches/:branch_id/queue_settings/:queue_setting_id/guest_queues/:id/:action',{},{
      pass:   { method: 'post', params: { action: 'pass'}},
      requeue:{ method: 'post', params: { action: 'requeue'}},
      accept: { method: 'post', params: { action: 'accept'}},
      cancel: { method: 'post', params: { action: 'cancel'}},
      notify: { method: 'post', params: { action: 'notify'}},
      reprint: { method: 'post', params: { action: 'reprint'}},
      print_pre_order: { method: 'post', params: { action: 'print_pre_order'}},
      get: {method: 'get', params: {}},
      bill: { method: 'get', params: { action: 'bill'}},
      pre_order_bill: { method: 'get', params: { action: 'pre_order_bill'}}
    })
}]);
Api.factory('TimeInterval', ['$resource',function($resource){
  return $resource('/branches/:branch_id/time_intervals/:id/:action', {},{
    });
}]);
Api.factory('EstimateClear', ['$resource',function($resource){
  return $resource('/branches/:branch_id/estimate_clear/:action',
      {
        branch_id: '@branch_id',
      }, {
      query: {method: 'get', isArray: true, cache: false},
      add: {method: 'post', params: {action: 'add'}},
      remove: {method: 'post', params: {action: 'remove'}},
      clear: {method: 'post', params: {action: 'clear'}},
      add_reciprocal: {method: 'post', params: {action: 'add_reciprocal'}},
      remove_reciprocal: {method: 'post', params: {action: 'remove_reciprocal'}}
    });
}]);
Api.factory('TempRechargeProduct', ['$resource',function($resource){
  return $resource('/temp_recharge_products/:id/:action', {},{});
}]);
Api.factory('CardWalletLog', ['$resource', function($resource) {
  return $resource('/vip_infos/:vip_info_id/card_wallet_logs/:id/:action', {}, {
    change_note: {method: 'put', params: {action: 'change_note'}, isArray: false}
  });
}]);
var order_common_actions = {
  cancel:   { method: 'post', params: { action: 'cancel'}},
  confirm:  { method: 'post', params: { action: 'confirm'}},
  complete: { method: 'post', params: { action: 'complete'}},
  change_vip_info: { method: 'post', params: { action: 'change_vip_info'}},
  unbind_vip_info: { method: 'post', params: { action: 'unbind_vip_info'}},
  credits_deduction: { method: 'post', params: { action: 'credits_deduction'}},
  cancel_credits_deduction: { method: "post", params: { action: 'cancel_credits_deduction'}},
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
}
Api.factory('RechargeOrder', ['$resource',function($resource){
  return $resource('/branches/:branch_id/recharge_orders/:id/:action',{},
        angular.extend({}, order_common_actions));
}]);
