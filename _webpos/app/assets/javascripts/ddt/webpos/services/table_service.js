WebposModules.add_service('table')
angular.module('webpos.services.table', []).
  factory('TableService', ['$resource', function($resource){
    var Table = $resource('/branches/:branch_id/tables/:id/:action', {},{
      open: { method: 'post', params: { action: 'open'}},
      get_changed_tables: { method: 'get', params: { action: 'get_changed_tables'}, isArray: true },
      get_reservation_tables: { method: 'get', params: { action: 'get_reservation_tables'}, isArray: true},
      update_guest_num: { method: 'post', params: {action: 'update_guest_num'}},
      clear: { method: 'post', params: { action: 'clear'}},
      check_out: { method: 'post', params: { action: 'check_out'}},
      cancel_check_out: { method: 'post', params: { action: 'cancel_check_out'}},
      force_clear: { method: 'post', params: { action: 'force_clear'}},
      get_consume_bill: { method: 'get', params: { action: 'get_consume_bill'}},
    });

    function query(branch_id, params, success){
      Table.query(angular.extend({branch_id: branch_id}, params), success);
    }

    function get(branch_id, id, success){
      Table.get({branch_id: branch_id, id: id}, success)
    }

    function open(branch_id, id, guest_num, success){
      Table.open({ branch_id: branch_id, id: id }, {guest_num: guest_num}, success)
    }

    function get_changed_tables(branch_id, last_refresh_at, success) {
      Table.get_changed_tables({branch_id: branch_id, last_refresh_at: last_refresh_at}, success);
    }

    function get_reservation_tables(branch_id, reservation_date, time_point_id, success){
      Table.get_reservation_tables({
        branch_id: branch_id,
        reservation_date: reservation_date,
        time_point_id: time_point_id
      }, success)
    }

    function clear(branch_id, table_id, success) {
      Table.clear({ branch_id: branch_id, id: table_id }, {}, success);
    }

    function check_out(branch_id, table_id, options,success){
      Table.check_out({branch_id: branch_id, id: table_id}, options||{}, success)
    }

    function cancel_check_out(branch_id, table_id, success){
      Table.cancel_check_out({branch_id: branch_id, id: table_id}, {}, success)
    }

    function update_guest_num(branch_id, table_id, guest_num, success){
      Table.update_guest_num({branch_id: branch_id, id: table_id}, {guest_num: guest_num}, success)
    }

    function force_clear(branch_id, table_id, success){
      Table.force_clear({branch_id: branch_id, id: table_id}, {}, success)
    }

    return {
      resource: Table,
      query: query,
      get: get,
      open: open,
      get_changed_tables: get_changed_tables,
      get_reservation_tables: get_reservation_tables,
      update_guest_num: update_guest_num,
      clear: clear,
      check_out: check_out,
      cancel_check_out: cancel_check_out,
      force_clear: force_clear
    }
  }])
