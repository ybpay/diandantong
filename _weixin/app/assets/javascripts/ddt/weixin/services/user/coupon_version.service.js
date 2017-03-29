
Ddt.factory('CouponVersionService', 
  ['$resource', 'DdtConst', function($resource, DdtConst){
    var CouponVersion = $resource(DdtConst.baseUrl + '/user/coupon_versions/:id/:action', {format: 'json'}, {
      exchange: { method: 'post', params: {action: 'exchange'}}
    })

    function query(params, success){
      CouponVersion.query(params, success)
    }

    function get(coupon_id, success){
      CouponVersion.get({id: coupon_id}, success)
    }

    function exchange(coupon_id, num, note, success){
      CouponVersion.exchange({id: coupon_id}, {num: num, note: note}, success)
    }
    return {
      get: get,
      query: query,
      exchange: exchange
    }
  }])
