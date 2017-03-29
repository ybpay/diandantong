WebposModules.add_service('groupon');
angular.module('webpos.services.groupon', []).
  factory('GrouponService', ['$resource', function($resource){

    var Groupon = $resource("/branches/:branch_id/groupons/:groupon_id/:action", {}, {
      available: { method: 'get', params: { action: 'available'}, isArray: true},
      exchange_by_id:  { method: 'post',params: { action: 'exchange_by_id'}},
      find_by_code:  { method: 'post',params: { action: 'find_by_code'}},
      exchange_by_code: { method: 'post', params: {action: 'exchange_by_code'}}
    })

    var available = function(branch_id, user_id, success){
      Groupon.available({branch_id: branch_id, user_id: user_id}, success);
    }

    var exchange_by_id = function(branch_id, user_id, groupon_id, success){
      Groupon.exchange_by_id({branch_id: branch_id, groupon_id: groupon_id},{user_id: user_id}, success);
    }

    var find_by_code = function(branch_id, exchange_code, success){
      Groupon.find_by_code({branch_id: branch_id}, {exchange_code: exchange_code}, success)
    }

    var exchange_by_code = function(branch_id, groupon_id, success){
      Groupon.exchange_by_code({branch_id: branch_id}, {base_coupon_id: groupon_id}, success)
    }


    return {
      available: available,
      exchange_by_id: exchange_by_id,
      find_by_code: find_by_code,
      exchange_by_code: exchange_by_code
    }
  }])
