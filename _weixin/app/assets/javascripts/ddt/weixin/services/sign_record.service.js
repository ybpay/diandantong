Ddt.factory('SignRecordService', [
    '$resource', 'DdtConst',
    function ($resource, DdtConst) {
      var SignRecord = $resource(DdtConst.baseUrl + '/user/sign_records/:id/:action', { format: 'json'}, {
        query: {method: 'GET', isArray: true, cache: true},
        get: {method: 'GET', cache: true}
      })

      function query(success){
        SignRecord.query({}, success)
      }

      function sign(success){
        SignRecord.save({}, {}, success)
      }

      return {
        query: query,
        sign: sign
      }
  }])