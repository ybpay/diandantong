WebposModules.add_service('combo')
angular.module('webpos.services.combo', []).
  factory('ComboService', ['$resource', '$filter', 'BranchService', 'VersionedCache', function($resource, $filter, BranchService, VersionedCache){

    var Combo = $resource('/branches/:branch_id/combos/:id/:action',{},{
      query: { method: 'get', isArray: true},
      add_combo_package: { method: 'post', params: { action: 'add_combo_package' } }
    })

    var combos_cache = {}
    function init_combos_cache(){
      combos_cache = {
        confirm_exist: function(branch_id){
          var This = this;
          if(this[branch_id] == undefined){
            var cache = VersionedCache.create(branch_id, 'combos', BranchService.cache_versions(branch_id).combos)
            cache.valid = function(order_type_str){
              if(cache.objs && cache.objs.length > 0){
                var replace_str = $filter('date')(new Date(), "THH:mm:ss.000+")
                var current_time= Date.parse(cache.objs[0].start_time.replace(/T.+\+/, replace_str))
                return _.filter(cache.objs, function(c){
                  var type_valid = (typeof order_type_str == 'undefined' ? true : c['support_'+order_type_str]);
                  /* !p.estimate_clear */
                  return c.on_shelf && type_valid && Date.parse(c.start_time) < current_time && current_time < Date.parse(c.end_time)
                })
              }else{
                return []
              }
            }
            this[branch_id] = cache;
          }
        }
      }
    }
    init_combos_cache();

    function query(branch_id, success){
      var version = BranchService.cache_versions(branch_id).combos
      combos_cache.confirm_exist(branch_id)
      if(combos_cache[branch_id].is_latest(version)){
        success(combos_cache[branch_id].valid())
      }else{
        Combo.query({branch_id: branch_id}, function(combos){
          combos_cache[branch_id].objs = combos;
          combos_cache[branch_id].version = version;
          combos_cache[branch_id].store();
          success(combos);
        })
      }
    }

    function add_combo_package(branch_id, combo_id, params, success){
      Combo.add_combo_package({ branch_id: branch_id, id: combo_id}, { combo_package: params }, success)
    }

    function clear_cache(branch_id){
      if(branch_id && combos_cache[branch_id]){
        combos_cache[branch_id].destroy();
        combos_cache[branch_id] = undefined;
      }else if(!branch_id){
        init_combos_cache();
      }
    }

    return {
      query: query,
      clear_cache: clear_cache,
      add_combo_package: add_combo_package
    }
  }])
