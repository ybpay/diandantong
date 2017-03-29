Ddt.factory('SharableCouponService',
  ['$rootScope', '$resource', 'DdtConst',
    function ($rootScope, $resource, DdtConst) {
      var SharableCoupon = $resource(DdtConst.baseUrl + '/user/sharable_coupons/:id/:action', { format: 'json' }, {
      })

      function query(success){
        SharableCoupon.query({}, success)
      }
      function get(sharable_coupon_id, success){
        SharableCoupon.get({id: sharable_coupon_id}, success);
      }

    return {
      query:query,
      get: get
    }
  }]);
