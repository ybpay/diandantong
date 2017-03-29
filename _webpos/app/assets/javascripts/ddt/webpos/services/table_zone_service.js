WebposModules.add_service('table_zone')
angular.module('webpos.services.table_zone', []).
  factory('TableZoneService', ['$resource', 'BranchService', 'VersionedCache', function($resource, BranchService, VersionedCache){
    var TableZone = $resource('/branches/:branch_id/table_zones/:id/:action', {},{
      with_reservation_time_points: { method: "get", params: { action: 'with_reservation_time_points'}, isArray: true}
    });

    var table_zones_cache = {};

    function init_table_zones_cache(){
      table_zones_cache = {
        confirm_exist: function(branch_id){
          if(this[branch_id] == undefined){
            this[branch_id] = VersionedCache.create(branch_id, 'table_zones', BranchService.cache_versions(branch_id).table_zones)
          }
        }
      }
    }
    init_table_zones_cache();

    function query(branch_id, success){
      var version = BranchService.cache_versions(branch_id).table_zones
      table_zones_cache.confirm_exist(branch_id)
      if(table_zones_cache[branch_id].is_latest(version)){
        success(table_zones_cache[branch_id].objs)
      }else{
        TableZone.query({branch_id: branch_id}, function(table_zones){
          table_zones_cache[branch_id].objs = table_zones;
          table_zones_cache[branch_id].version = version;
          table_zones_cache[branch_id].store()
          success(table_zones)
        })
      }
    }

    function get_ban_product_ids(branch_id, id, success){
      query(branch_id, function(table_zones){
        var ban_product_ids = [];
        angular.forEach(table_zones, function(table_zone){
          if(table_zone.id == id){
            ban_product_ids = table_zone.webpos_ban_product_ids || [];
          }
        })
        success(ban_product_ids)
      })
    }

    function with_reservation_time_points(branch_id, success){
      TableZone.with_reservation_time_points({branch_id: branch_id}, success)
    }

    return {
      query: query,
      get_ban_product_ids: get_ban_product_ids,
      with_reservation_time_points: with_reservation_time_points
    }
  }])
