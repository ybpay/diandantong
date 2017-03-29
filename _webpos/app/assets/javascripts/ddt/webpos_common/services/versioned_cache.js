WebposModules.add_service('versioned_cache')
angular.module('webpos.services.versioned_cache', [])
.factory('VersionedCache',[
  'LocalStorageCache',
  function(LocalStorageCache){

    var Cache = function(ls, branch_id, type, version){
      this.ls = ls;
      this.branch_id = branch_id;
      this.init_version = (typeof version == 'undefined') ? Date.now() : parseInt(version);
      this.objs = null;
      this.cache_key = type + '_' + branch_id
      this.version_key = type + '_version_' + branch_id;

      this.update = function(new_obj){
        this.objs = this.objs || [];
        var idx = null;
        angular.forEach(this.objs, function(obj, index){
          if(obj.id == new_obj.id){ 
            idx = index;
            return;
          }
        })
        if(idx){
          this.objs[idx] = new_obj
        }else{
          this.objs.push(new_obj)
        }
        var cache_version = Date.parse(new_obj.cache_version);
        if(this.version < cache_version){
          this.version = cache_version
        }
      }

      this.batch_update = function(new_objs){
        var This = this;
        angular.forEach(new_objs, function(new_obj){
          This.update(new_obj);
        });
      }

      this.is_latest = function(version){
        return this.version == version
      }

      this.store = function(){
        this.ls.set(this.cache_key, this.objs)
        this.ls.set(this.version_key, this.version)
      }

      this.restore = function(){
        return this.ls.get(this.cache_key)
      }

      this.destroy = function(){
        this.ls.set(this.cache_key, null)
        this.ls.set(this.version_key, null)
      }

      this.init = function(){
        this.version = this.ls.get(this.version_key) || -1;
        if(this.version == this.init_version){
          var cache_objs = this.restore();
          if(cache_objs){
            this.objs = cache_objs;
          }
        }
      }
      this.init();
    }

    function create(branch_id, type, new_version){
      return new Cache(LocalStorageCache, branch_id, type, new_version)
    }

    return { create: create}
  }
])
