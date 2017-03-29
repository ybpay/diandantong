WebposModules.add_service('branch')
angular.module('webpos.services.branch', []).
  factory('BranchService', ['$rootScope', 'Branch', 'WirePrinterService', function($rootScope, Branch, WirePrinterService){

    function get(branch_id, success){
      update_cache_versions(branch_id)
      Branch.get({id: branch_id}, function(branch){
        $rootScope.set_branch(branch)
        WirePrinterService.set_manual_print(!branch.is_current_print_when_place);
        success(branch)
      })
    }

    var versions = {} /* {branch_id: {:table_zones, :categories, :products, :combos}} */
    var times    = {} /* {branch_id: 1467770193734} */
    var loading  = false;
    var interval = 30 * 1000;

    function update_cache_versions(branch_id, success){
      if(!loading){
        var cache_version = versions[branch_id];
        var last_query_cache_version_at = times[branch_id];
        loading = true
        if(last_query_cache_version_at == null || Date.now() - last_query_cache_version_at > interval){
        Branch.cache_versions({id: branch_id}, function(cache_version){
            times[branch_id]    = Date.now();
            versions[branch_id] = cache_version;
            if(success){success(cache_version)}
            loading = false
          })
        }else{
          if(success){success(cache_version)}
          loading = false
        }
      }
    }

    function cache_versions(branch_id){
      if(versions[branch_id]){
        return versions[branch_id];
      }else{
        return {categories: 0, products: 0, combos: 0, table_zones: 0}
      }
    }

    function get_waiter_names(params){
      return Branch.get_waiter_names(params)
    }

    return {
      get: get,
      get_waiter_names: get_waiter_names,
      cache_versions: cache_versions
    }
  }])
