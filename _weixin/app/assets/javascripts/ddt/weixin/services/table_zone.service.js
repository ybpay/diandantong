Ddt.factory('TableZoneService',
  ['DdtConst', '$resource',
  function (DdtConst, $resource) {
    var TableZone = $resource(DdtConst.baseUrl + '/branches/:branch_id/table_zones/:id/:action', { format: 'json'}, {
    	query: {method: 'GET', isArray: true, cache: true},
      	get: {method: 'GET', cache: true}
    })
    function query(branch_id, success){
      TableZone.query({ branch_id: branch_id }, success)
    }
    return {
      query: query
    }
}]);
