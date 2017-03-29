Ddt.factory('RechargeProductService',
  ['DdtConst', '$resource',
    function (DdtConst, $resource) {
      var RechargeProduct = $resource(DdtConst.baseUrl + '/recharge_products/:action', {format: 'json'}, {
        query: {method: 'GET', isArray: true, cache: true},
      });

      return {
        query: function (success) {
          RechargeProduct.query({}, success);
        }

      }
    }]
);
