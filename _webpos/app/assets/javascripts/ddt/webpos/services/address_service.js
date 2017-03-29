WebposModules.add_service('address')
angular.module('webpos.services.address', []).
  factory('AddressService', ['$rootScope', '$resource',
    function($rootScope, $resource){
      var Address = $resource('/addresses/:action', {},{
        search:  { method: 'get',   params: { action: 'search'}, isArray: true}
      });

      function search(phone, success){
        Address.search({ phone: phone }, success)
      }

      return {
        search: search
      }
    }])