Ddt.module('ddt_app.services.favorite_branch', []).
  factory('FavoriteBranchService', ['$rootScope', '$resource', 'DdtConst',
    function ($rootScope, $resource, DdtConst) {
      var FavoriteBranch = $resource(DdtConst.baseUrl + '/user/favorite_branches/:id/:action', {format: 'json'}, {
        destroy: { method: 'post', params: {action: 'delete'}}
      });

      function query(success) {
        FavoriteBranch.query({}, success);
      }

      function save(branch_id, success){
        FavoriteBranch.save({id: branch_id}, success);
      }

      function destroy(branch_id, success){
        FavoriteBranch.destroy({id: branch_id}, {}, success);
      }

      return {
        query: query,
        save: save,
        destroy: destroy
      }
    }
  ]);
