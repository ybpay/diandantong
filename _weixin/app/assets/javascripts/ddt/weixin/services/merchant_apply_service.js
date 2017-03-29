Ddt.factory('MerchantApplyService', ['$resource', '$location', 'DdtConst',
  function($resource, $location, DdtConst) {
    var MerchantApply = $resource(DdtConst.baseUrl + '/user/merchant_apply/:action', {format: 'json'}, {
      cancel: {method: 'post', params: {action: 'cancel'}}
    });

    return {
      get: MerchantApply.get,
      save: MerchantApply.save,
      cancel: MerchantApply.cancel
    };
  }
]);
