WebposModules.add_service('vip_info');
angular.module('webpos.services.vip_info',[]).
  factory("VipInfoService", ["$resource", function($resource){

    var VipInfo = $resource('/vip_infos/:id/:action',{},{
      merge: { method: 'post', params: { action: 'merge'}},
      become: { method: 'post', params: { action: 'become'}},
      reject:{ method: 'post', params: { action: 'reject'}},
      update:{ method: 'post'},
      get_by_scan_code: { method: 'get', params: { action: 'get_by_scan_code'}}
    })

    function query(params, success){
      VipInfo.query(params, success)
    }

    function get_by_scan_code(scan_code, success){
      VipInfo.get_by_scan_code({scan_code: scan_code}, success)
    }

    function get(vip_info_id, success) {
      VipInfo.get({id: vip_info_id}, success);
    }

    function create(new_vip_info, success){
      VipInfo.save({}, { vip_info: new_vip_info }, success)
    }

    function update(vip_info, success){
      VipInfo.update({id: vip_info.id}, {vip_info: vip_info}, success)
    }

    function merge(vip_info_id, source_vip_info_id, success){
      VipInfo.merge({ id: vip_info_id }, { source_vip_info_id: source_vip_info_id }, success )
    }

    function become(vip_info, success){
      VipInfo.become({id: vip_info.id}, {vip_info: vip_info}, success)
    }

    function reject(vip_info_id, success){
      VipInfo.reject({id: vip_info_id}, {}, success)
    }

    var binds = {}
    var current_bind_vip_id = null

    function set_bind(vip_info_id, order){
      binds[vip_info_id] = order
      current_bind_vip_id = (typeof order == 'undefined') ? null : vip_info_id
    }

    function get_bind_order(vip_info_id){
      return binds[vip_info_id]
    }

    function curr_bind_id(){
      return current_bind_vip_id
    }

    return {
      query: query,
      get_by_scan_code: get_by_scan_code,
      get: get,
      create: create,
      merge: merge,
      reject: reject,
      update: update,
      become: become,
      get_bind_order: get_bind_order,
      set_bind: set_bind,
      curr_bind_id: curr_bind_id
    }

  }])
