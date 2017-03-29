Ddt.factory('TuanService',
  ['DdtConst', '$resource','$rootScope',
  function (DdtConst, $resource, $rootScope) {

    var Tuan = $resource(DdtConst.baseUrl + '/tuans/:id/:action', { format: 'json'}, {
      query: {method: 'GET', isArray: true, cache: true},
      get: {method: 'GET', cache: true}
    });

    function query(query, success){
      if (typeof query == 'function') {
        Tuan.query({}, query);
      }else{
        Tuan.query(query, success);
      }
    }

    function get(tuan_id, success){
      Tuan.get({ id: tuan_id }, success)
    }

    function show_on_index(success){
      success($rootScope.current_shop.tuans_show_on_index)
    }

    return {
      query: query,
      get: get,
      show_on_index: show_on_index
    }
}]);
