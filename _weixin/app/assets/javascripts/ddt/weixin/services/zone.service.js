Ddt.factory('ZoneService',
  ['DdtConst', '$resource',
    function (DdtConst, $resource) {
      var r = $resource(DdtConst.baseUrl + '/zones/:action', {format: 'json'}, {
        query: {method: 'GET', isArray: true, cache: true},
        get_zone_by_city: {method: 'GET',cache: true, params: {action: 'get_zone_by_city'}}
      });

      return {
        //
        // query 支持 hierarchy 参数，返回层次化的区域
        //
        query: function (query, success) {
          r.query(query, success);
        },

        // 城市反查区域
        get_zone_by_city: function (city, success) {
          r.get_zone_by_city(city, success);
        }
      }
    }]
);
