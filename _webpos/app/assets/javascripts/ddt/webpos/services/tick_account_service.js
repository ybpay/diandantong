WebposModules.add_service('tick_account')
angular.module('webpos.services.tick_account', []).
  factory('TickAccountService', ['$resource', function($resource){
    var TickAccount = $resource('/branches/:branch_id/tick_accounts/:id/:action',{},{
      query: { method: 'get', cache: true, isArray: true }
    })

    function query(branch_id, success){
      TickAccount.query({branch_id: branch_id}, success)
    }

    return {
      query: query
    }
  }])
