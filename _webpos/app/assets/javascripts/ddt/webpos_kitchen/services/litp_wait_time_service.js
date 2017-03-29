WebposModules.add_service('litp_wait_time_service')
angular.module('webpos.services.litp_wait_time_service', []).
  factory('LitpWaitTimeService', ["LocalStorageCache" , function(LocalStorageCache){

    var settings = LocalStorageCache.get("litp_wait_time_setting") || {}
    function get(variant_id){
      return settings[variant_id + ""]
    }

    function set(variant_id, minutes){
      settings[variant_id+""] = minutes
      LocalStorageCache.set("litp_wait_time_setting", settings)
    }

    return {
      get: get,
      set: set
    }
  }])