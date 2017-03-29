WebposModules.add_service('queue_setting')
angular.module('webpos.services.queue_setting', []).
  factory('QueueSettingService', ['$resource', function($resource){
    var QueueSetting = $resource('/branches/:branch_id/queue_settings/:id/:action',{},{
      query: { method: 'get', isArray: true, cache: true},
      history: { method: 'get', isArray: true, params: { action: 'history'}},
      queue_states: { method: 'get', isArray: true, params: {action: 'queue_states'}},
      create_guest_queue: { method: 'post', params: {action: 'create_guest_queue'}},
      set_notify_number_in_advance: {method: 'post', isArray: true, params: {action: 'set_notify_number_in_advance'}}
    })

    function query(branch_id, success){
      QueueSetting.query({branch_id: branch_id}, success)
    }

    function history(params, success){
      QueueSetting.history(params, success)
    }

    function queue_states(branch_id, success){
      QueueSetting.queue_states({branch_id: branch_id}, success)
    }

    function create_guest_queue(branch_id, guest_queue,bill_type, success){
      QueueSetting.create_guest_queue({branch_id: branch_id}, {guest_queue: guest_queue, bill_type: bill_type}, success)
    }

    function set_notify_number_in_advance(branch_id, queue_setting_id, number, success){
      QueueSetting.set_notify_number_in_advance({
        branch_id: branch_id,
        id: queue_setting_id
      },{
        notify_number_in_advance: number
      }, success);
    }

    return {
      query: query,
      history: history,
      queue_states: queue_states,
      create_guest_queue: create_guest_queue,
      set_notify_number_in_advance: set_notify_number_in_advance
    }
  }])
