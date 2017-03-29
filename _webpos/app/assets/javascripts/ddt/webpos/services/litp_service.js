WebposModules.add_service('litp')
angular.module('webpos.services.litp',[]).
  factory("LitpService",["$resource", function($resource){

    var Litp = $resource("/branches/:branch_id/litps/:id/:action",{},{
      query: { method: "get", isArray: true },
      counts: { method: "get", params: {action: "counts"} },
      cooks: { method: "get", params: {action: "cooks"}, isArray: true },
      confirm: { method: "put", params: {action: "confirm"}},
      complete: { method: "put", params: {action: "complete"}},
    });

    return Litp;
  }]);
