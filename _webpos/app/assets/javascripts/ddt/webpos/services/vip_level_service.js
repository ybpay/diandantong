WebposModules.add_service('vip_level');
angular.module('webpos.services.vip_level',[]).
  factory("VipLevelService", ["$resource", function($resource){
    var VipLevel = $resource('/vip_levels',{},{})

    function query(success){
      VipLevel.query({}, success)
    }

    return {
      query: query
    }

  }])