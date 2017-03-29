Ddt.module("ddt_app.services.combo", []).
  factory('ComboService', ['$resource', 'DdtConst',
    function ($resource, DdtConst) {
      var Combo = $resource(DdtConst.baseUrl + '/branches/:branch_id/combos/:id/:action', { format: 'json'}, {
        query: {method: 'GET', isArray: true, cache: true},
        get: {method: 'GET', cache: true},
        add_combo_package: {method: 'post', params: {action: 'add_combo_package'}}
      })

      function query(branch_id, order_type, success){
        Combo.query({ branch_id: branch_id , order_type: order_type }, success)
      }

      function add_combo_package(branch_id, params, success){
        Combo.add_combo_package({ branch_id: branch_id, id: params.combo_id}, { combo_package: params }, success)
      }

    return {
      query: query,
      add_combo_package: add_combo_package
    }
  }]);
