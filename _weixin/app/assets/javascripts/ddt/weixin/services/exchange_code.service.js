Ddt.factory('ExchangeCodeService',
  ['$rootScope', '$resource', 'DdtConst',
    function ($rootScope, $resource, DdtConst) {
      var ExchangeCode = $resource(DdtConst.baseUrl + '/exchange_codes/:id/:action', { format: 'json' }, {
        get_permissions: { method: 'get', params: { action: 'get_permissions', nomask: true}},
        get_qrcode: { method: 'get', params: { action: 'get_qrcode'}},
        exchange: {method: 'post', params: { action: 'exchange'}}
      })

      function get( exchange_code_id, success){
        ExchangeCode.get({
          id: exchange_code_id
        }, success);
      }

      function get_permissions(exchange_code_id, success){
        ExchangeCode.get_permissions({
          id: exchange_code_id
        }, success);
      }

      function get_qrcode(exchange_code_id, success){
        ExchangeCode.get_qrcode({
          id: exchange_code_id
        }, success);
      }

      function exchange(exchange_code_id, success){
        ExchangeCode.exchange({
          id: exchange_code_id
        }, {}, success);
      }

    return {
      get: get,
      get_permissions: get_permissions,
      get_qrcode: get_qrcode,
      exchange: exchange
    }
  }]);
