WebposModules.add_service('guest_queue')
angular.module('webpos.services.guest_queue', []).
  factory('GuestQueueService', ['$resource', 'QueueSettingService', function($resource, QueueSettingService){
    var GuestQueue = $resource('/branches/:branch_id/queue_settings/:queue_setting_id/guest_queues/:id/:action',{},{
      pass:   { method: 'post', params: { action: 'pass'}},
      requeue:{ method: 'post', params: { action: 'requeue'}},
      accept: { method: 'post', params: { action: 'accept'}},
      cancel: { method: 'post', params: { action: 'cancel'}},
      notify: { method: 'post', params: { action: 'notify'}},
      reprint: { method: 'post', params: { action: 'reprint'}},
      print_pre_order: { method: 'post', params: { action: 'print_pre_order'}},
      get: {method: 'get', params: {}},
      bill: { method: 'get', params: { action: 'bill'}},
      pre_order_bill: { method: 'get', params: { action: 'pre_order_bill'}}
    })



    function set_cache(branch_id, queue_setting_id, guest_queues){
      var key = get_key(branch_id, queue_setting_id)
      set_ddb_cache(key, guest_queues)
    }

    function get_cache(branch_id, queue_setting_id){
      var key = get_key(branch_id, queue_setting_id);
      var guest_queues = get_ddb_cache(key);
      if(guest_queues == null){
        set_cache(branch_id, queue_setting_id, [])
        return [];
      }else{
        return guest_queues;
      }
    }

    function get_key(branch_id, queue_setting_id){
      if(queue_setting_id){
        return '__branch_'+branch_id+'_queue_'+queue_setting_id
      }else{
        return '__branch_'+branch_id+'_queue_history'
      }
    }

    function query(params, success){
      if(params.queue_setting_id){
        GuestQueue.query(params, function(guest_queues){
          set_cache(params.branch_id, params.queue_setting_id, guest_queues)
          success(guest_queues);
        })
      }else{
        QueueSettingService.history(params, function(guest_queues){
          set_cache(params.branch_id, null, guest_queues)
          success(guest_queues);
        })
      }
    }

    function pass(branch_id, queue_setting_id, id, success){
      GuestQueue.pass({branch_id: branch_id, queue_setting_id: queue_setting_id, id:id},{},success)
    }

    function requeue(branch_id, queue_setting_id, id, success){
      GuestQueue.requeue({branch_id: branch_id, queue_setting_id: queue_setting_id, id:id},{},success)
    }

    function accept(branch_id, queue_setting_id, id, success){
      GuestQueue.accept({branch_id: branch_id, queue_setting_id: queue_setting_id, id:id},{},success)
    }

    function cancel(branch_id, queue_setting_id, id, success){
      GuestQueue.cancel({branch_id: branch_id, queue_setting_id: queue_setting_id, id:id},{},success)
    }

    function notify(branch_id, queue_setting_id, id, success){
      GuestQueue.notify({branch_id: branch_id, queue_setting_id: queue_setting_id, id:id},{},success)
    }

    function reprint(branch_id, queue_setting_id, id, success){
      GuestQueue.reprint({branch_id: branch_id, queue_setting_id: queue_setting_id, id:id},{},success)
    }

    function print_pre_order(branch_id, queue_setting_id, id, success){
      GuestQueue.print_pre_order({branch_id: branch_id, queue_setting_id: queue_setting_id, id:id},{},success)
    }

    function bill(branch_id, queue_setting_id, id, bill_type, success){
      GuestQueue.bill({branch_id: branch_id, queue_setting_id: queue_setting_id, id:id, bill_type: bill_type},{},success)
    }

    function pre_order_bill(branch_id, queue_setting_id, id, bill_type, success){
      GuestQueue.pre_order_bill({branch_id: branch_id, queue_setting_id: queue_setting_id, id:id, bill_type: bill_type},{},success)
    }

    function create(branch_id, queue_setting_id, new_guest, success){
      GuestQueue.save({branch_id: branch_id, queue_setting_id: queue_setting_id},{
        guest_queue: new_guest
      },success)
    }

    function get(branch_id, queue_setting_id, id, success){
      GuestQueue.get({branch_id: branch_id, queue_setting_id: queue_setting_id, id: id}, success)
    }

    return {
      get: get,
      query: query,
      pass:  pass,
      requeue: requeue,
      accept:accept,
      cancel:cancel,
      notify:notify,
      create:create,
      reprint:reprint,
      print_pre_order:print_pre_order,
      pre_order_bill:pre_order_bill,
      bill: bill,
      get_cache: get_cache
    }
  }])
