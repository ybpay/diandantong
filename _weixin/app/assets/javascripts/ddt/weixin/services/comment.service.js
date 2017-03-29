Ddt.module("ddt_app.services.comment", []).
  factory('CommentService', ['$resource', 'DdtConst',
    function ($resource, DdtConst) {
      var Comment = $resource(DdtConst.baseUrl + '/branches/:branch_id/comments/:action', { format: 'json'}, {
        query: {method: 'GET', isArray: true, cache: true},
        get: {method: 'GET', cache: true}
      })

      function query(branch_id, success){
        Comment.query({ branch_id: branch_id }, success)
      }

    return {
      query: query
    }
  }]);
