Ddt.
    factory('GuestQueueService', ['$http', '$rootScope' , '$resource', 'DdtConst',
      function ($http, $rootScope, $resource, DdtConst) {

      var GuestQueue = $resource(DdtConst.baseUrl + '/branches/:branch_id/guest_queue/:action', { format: 'json' }, {
        get: {method: 'get', params: {nomask: true}},
        cancel: { method: 'post', params: { action: 'cancel' }},
        bind_user: { method: 'post', params: { action: 'bind_user'}},
        get_by_qr_code: { method: 'get', params: { action: 'get_by_qr_code'}},
      })
      function get(branch_id, success){
        GuestQueue.get({branch_id: branch_id}, success);
      }

      function create(branch_id, guest_guest_params, success){
        GuestQueue.save({branch_id: branch_id}, {
          guest_queue: guest_guest_params
        }, success);
      }

      function cancel(branch_id, success){
        GuestQueue.cancel({branch_id: branch_id}, {}, success);
      }

      function get_by_qr_code(branch_id, qr_code_id, success){
        GuestQueue.get_by_qr_code({branch_id: branch_id, qr_code_id: qr_code_id}, success);
      }

      function bind_user(branch_id, guest_queue_id, success){
        GuestQueue.bind_user({ branch_id: branch_id }, { guest_queue_id: guest_queue_id }, success)
      }

      return {
        get:get,
        bind_user: bind_user,
        get_by_qr_code: get_by_qr_code,
        create:create,
        cancel:cancel
      }
    }]);
