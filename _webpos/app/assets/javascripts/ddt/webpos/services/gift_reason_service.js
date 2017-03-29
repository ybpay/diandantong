WebposModules.add_service('gift_reason');
angular.module('webpos.services.gift_reason',[]).
  factory("GiftReasonService", ["$resource", function($resource){
    var GiftReason = $resource('/gift_reasons',{},{
      query: { method: 'get', isArray: true, cache: true},
    })

    function query(success){
      GiftReason.query({}, success)
    }

    return {
      query: query
    }

  }])