WebposModules.add_service('category')
angular.module('webpos.services.category', []).
  factory('CategoryService', ['$resource', '$q', 'BranchService', 'VersionedCache',
  function($resource, $q, BranchService, VersionedCache){
    var Category = $resource('/branches/:branch_id/categories/:id/:action',{},{
      query: { method: 'get', isArray: true}
    })

    var categories_cache = {}
    function init_categories_cache(){
      categories_cache = {
        confirm_exist: function(branch_id){
          if(this[branch_id] == undefined){
            this[branch_id] = VersionedCache.create(branch_id, 'categories', BranchService.cache_versions(branch_id).categories)
          }
        }
      }
    }
    init_categories_cache();

    // success: function(categories, fromCache)
    function query(branch_id, success){
      var version = BranchService.cache_versions(branch_id).categories;
      categories_cache.confirm_exist(branch_id)
      if(categories_cache[branch_id].is_latest(version)){
        success(categories_cache[branch_id].objs, true)
      }else{
        Category.query({branch_id: branch_id}, function(categories){
          categories_cache[branch_id].objs = categories;
          categories_cache[branch_id].version = version;
          categories_cache[branch_id].store()
          success(categories, false)
        })
      }
    }

    function clear(branch_id){
      var defer = $q.defer();

      if(branch_id && categories_cache[branch_id]){
        categories_cache[branch_id].destroy();
        categories_cache[branch_id] = undefined;
      }else if(!branch_id){
        init_categories_cache();
      }
      defer.resolve();
      return defer.promise;
    }

    return {
      clear: clear,
      query: query
    }
  }])
