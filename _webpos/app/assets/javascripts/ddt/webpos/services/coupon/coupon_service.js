WebposModules.add_service('coupon')
angular.module('webpos.services.coupon',[]).
  factory('CouponService', ['$resource', function($resource){

    var Coupon = $resource("/branches/:branch_id/coupons/:coupon_id/:action", {}, {
      search:    { method: 'get', params: { action: 'search'}},
      available: { method: 'get', params: { action: 'available'}, isArray: true},
      apply:     { method: 'post',params: { action: 'apply'}},
      find_by_code:  { method: 'post', params: { action: 'find_by_code'}},
      exchange_by_code: {method: 'post', params: { action: 'exchange_by_code'}}
    })

    function search(branch_id, code, success){
      Coupon.search({ branch_id: branch_id, code: code }, success)
    }

    var available = function(branch_id, user_id, success){
      Coupon.available({branch_id: branch_id, user_id: user_id}, success);
    }

    var find_by_code = function(branch_id, exchange_code, success){
      Coupon.find_by_code({branch_id: branch_id}, {exchange_code: exchange_code}, success)
    }

    var exchange_by_code = function(branch_id, coupon_id, success){
      Coupon.exchange_by_code({branch_id: branch_id}, {base_coupon_id: coupon_id}, success)
    }

    var apply = function(branch_id, coupon_id, user_id, order_id, success){
      Coupon.apply({branch_id: branch_id, coupon_id: coupon_id},{
        user_id: user_id,
        order_id: order_id
      }, success);
    }

    return {
      search: search,
      available: available,
      apply: apply,
      find_by_code: find_by_code,
      exchange_by_code: exchange_by_code
    }
  }])
