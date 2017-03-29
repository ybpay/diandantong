WebposModules.add_service('printer')
angular.module('webpos.services.printer',[]).
  factory('PrinterService',['$resource', function($resource){
    var Printer = $resource('/branches/:branch_id/printers/:action',{},{
      query: { method: 'get', isArray: true, cache: true },
      reprint: { method: "post", params: {action: "reprint"}},
      get_states: {method: "get", params: {action: "get_states"}, isArray: true},
      test_print: {method: 'post', params: {action: 'test_print'}},
      test_print_all: {method: 'post', params: {action: 'test_print_all'}}
    })

    function query(branch_id, success){
      Printer.query({branch_id: branch_id}, success);
    }

    function reprint(branch_id, printer_ids, note, order_id, success){
      Printer.reprint({branch_id: branch_id}, {
        order_id: order_id,
        printer_ids: printer_ids,
        note: note
      }, success);
    }

    function get_states(branch_id, success){
      Printer.get_states({branch_id: branch_id}, success)
    }

    function test_print(branch_id, printer_id, success){
      Printer.test_print({branch_id: branch_id, id: printer_id}, success)
    }

    function test_print_all(branch_id, success){
      Printer.test_print_all({branch_id: branch_id}, success)
    }

    return{
      query: query,
      reprint: reprint,
      get_states: get_states,
      test_print: test_print,
      test_print_all: test_print_all
    }
  }])