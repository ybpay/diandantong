Ddt.factory('TableService',
  ['DdtConst', '$resource',
    function (DdtConst, $resource) {
      var Table = $resource(DdtConst.baseUrl + '/branches/:branch_id/tables/:id/:action', {format: 'json'}, {
        get: {method: 'GET', cache: false},
        open: {method: 'POST', params: {action: 'open'}},
        get_all: {method: 'GET', params: {action: 'get_all'}, isArray: true}
      });

      function get(branch_id, id, success) {
        Table.get({branch_id: branch_id, id: id}, success)
      }

      function open(branch_id, id, guest_num, success){
        Table.open({branch_id: branch_id, id: id},{guest_num: guest_num}, success)
      }

      function get_all(branch_id, success){
        Table.get_all({branch_id: branch_id}, success)
      }

      return {
        get: get,
        open: open,
        get_all: get_all
      }
    }]);
