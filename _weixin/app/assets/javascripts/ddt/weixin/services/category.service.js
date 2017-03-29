Ddt.module('ddt_app.services.category', []).
  factory('CategoryService', ['$rootScope' , '$resource', 'DdtConst',
    function ($rootScope, $resource, DdtConst) {
    var Category = $resource(DdtConst.baseUrl + '/branches/:branch_id/categories/:id/:action', { format: 'json' },{
      query: {method: 'GET', isArray: true, cache: true}
    });

    function query(branch_id, support_type, success){
      Category.query({
        branch_id: branch_id,
        support_type: support_type
      }, success)
    }

    return {
      query: query
    }
  }]);
