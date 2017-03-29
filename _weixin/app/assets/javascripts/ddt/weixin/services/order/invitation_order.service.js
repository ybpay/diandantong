Ddt.factory('InvitationOrderService',
  ['$resource', 'DdtConst',
    function ($resource, DdtConst) {
      
      var res = $resource(DdtConst.baseUrl + '/branches/:branch_id/invitation_orders/:id/:action', {format: 'json'},{
        agree:      { method: 'post', params: { action: 'agree'}},
        disagree:      { method: 'post', params: { action: 'disagree'}}
      });

      var service = {};
      
      angular.forEach('get agree disagree'.split(' '), function(name){
        service[name] = function(){
          res[name].apply(res, arguments);
        }
      });


      return service;
    }]
);