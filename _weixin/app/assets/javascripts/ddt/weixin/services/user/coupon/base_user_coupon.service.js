Ddt.factory('BaseUserCouponService', [
    '$rootScope' , '$resource', 'DdtConst',
    function ( $rootScope, $resource, DdtConst) {
      var common_actions = {
        apply_refund: { method: 'post', params: {action: 'apply_refund'}},
        cancel_apply_refund: { method: 'post', params: {action: 'cancel_apply_refund'}},
      }
      var Coupon = $resource(DdtConst.baseUrl + '/user/coupons/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions))
      var Groupon = $resource(DdtConst.baseUrl + '/user/groupons/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions))
      var Voucher = $resource(DdtConst.baseUrl + '/user/vouchers/:id/:action',{ format: 'json' },
          angular.extend({}, common_actions))

      function get_resource(coupon_type){
        var resource;
        switch(coupon_type){
          case 'coupon':   ; resource = Coupon   ; break ;
          case 'groupon':  ; resource = Groupon  ; break ;
          case 'voucher':  ; resource = Voucher  ; break ;
        }
        return resource
      }

      function query(coupon_type, params, success){
        var resource = get_resource(coupon_type)
        resource.query(params, success)
      }

      function get(coupon_type, base_coupon_id, success){
        var resource = get_resource(coupon_type)
        resource.get({id: base_coupon_id}, success)
      }

      function apply_refund(coupon_type, base_coupon_id, success){
        var resource = get_resource(coupon_type)
        resource.apply_refund({id: base_coupon_id},{}, success)
      }

      function cancel_apply_refund(coupon_type, base_coupon_id, success){
        var resource = get_resource(coupon_type)
        resource.cancel_apply_refund({id: base_coupon_id}, {}, success)
      }

    return {
      get_resource: get_resource,
      query: query,
      get: get,
      apply_refund: apply_refund,
      cancel_apply_refund: cancel_apply_refund
    }
  }]);
