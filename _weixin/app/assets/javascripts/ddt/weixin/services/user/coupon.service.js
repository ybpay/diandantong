Ddt.factory('CouponService',
  ['$rootScope', '$resource', 'DdtConst',
    function ($rootScope, $resource, DdtConst) {
      var Coupon = $resource(DdtConst.baseUrl + '/user/coupons/:id/:action', { format: 'json' }, {
        status: { method: 'get', params: {action: 'status'}}
      })

      function query(success){
        Coupon.query({}, success)
      }

      function get(coupon_id, success){
        Coupon.get({ id: coupon_id }, success)
      }

      function status(success){
        Coupon.status({}, success)
      }

    return {
      query:query,
      get:get,
      status: status
    }
  }]);
