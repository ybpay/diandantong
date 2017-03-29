WebposModules.add_service('reservation_info')
angular.module('webpos.services.reservation_info', []).
  factory('ReservationInfoService', ['$rootScope', '$resource',
    function($rootScope, $resource){
      var ReservationInfo = $resource('/reservation_infos/:action', {},{
        search:  { method: 'get',   params: { action: 'search'}, isArray: true}
      });

      function search(phone, success){
        ReservationInfo.search({ phone: phone }, success)
      }

      return {
        search: search
      }
    }])