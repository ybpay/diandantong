WebposModules.add_service('local_storage_cache')
angular.module('webpos.services.local_storage_cache', []).
  factory('LocalStorageCache', [function(){

    var ls_version_key = 'ls_ddb_version';
    function set(k, v){
      var key = '__ddb_'+k;
      localStorage.setItem(key, JSON.stringify(v))
    }

    function get(k){
      var version = localStorage.getItem(ls_version_key)
      if(version != ls_version){
        clear();
        localStorage.setItem(ls_version_key, ls_version)
        return null;
      }

      var key = '__ddb_'+k;
      var v = localStorage.getItem(key)
      if(v == null || v == undefined || v == "undefined") {
        return null
      }else{
        return JSON.parse(v)
      }
    }

    function clear(){
      angular.forEach(localStorage, function(k, v){
        if(k.match(/__ddb_/)){
          localStorage.removeItem(k);
        }
      })
    }

    return {
      get: get,
      set: set,
      clear: clear
    }
  }])