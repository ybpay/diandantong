Ddt.factory('SharingCouponService',
  ['$rootScope', '$resource', 'DdtConst',
    function ($rootScope, $resource, DdtConst) {
      var SharableCoupon = $resource(DdtConst.baseUrl + '/sharable_coupons/:id/:action', { format: 'json' }, {
        receive: { method: 'post', params: { action: 'receive' }}
      })

      function get(sharable_coupon_id, success){
        SharableCoupon.get({id: sharable_coupon_id}, success);
      }


      function receive(sharable_coupon_id, success){
        SharableCoupon.receive({id: sharable_coupon_id}, {}, success);
      }

    return {
      receive:receive,
      get: get
    }
  }]);
