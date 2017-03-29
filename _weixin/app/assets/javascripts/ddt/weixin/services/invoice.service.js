Ddt.module("ddt_app.services.invoice",[]).
  factory('InvoiceService',['$resource', 'DdtConst',
    function ($resource, DdtConst) {
      var Invoice = $resource(DdtConst.baseUrl + '/branches/:branch_id/invoices', { format: 'json'}, {
        create: {method: 'POST'}
      })

      function create(branch_id, order_id, invoice, success){
        Invoice.create({branch_id: branch_id, order_id: order_id},{
          invoice: invoice
        }, success);
      }

      return {
        create: create
      }
    }]);
