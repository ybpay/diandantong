WebposModules.add_service('print')
angular.module('webpos.services.print',[]).
  factory('PrintService',['WirePrinterService', 'GuestQueue',
    function(WirePrinterService, GuestQueue){

      function print_queue_bill(guest_queue){
        if(WirePrinterService.has_object()){
          //webpos打印
          bill_type = WirePrinterService.get_printer_width()
          GuestQueue.bill({
            branch_id: guest_queue.branch_id,
            queue_setting_id: guest_queue.queue_setting_id,
            id: guest_queue.id,
            bill_type: bill_type
          }).$promise.then(function(resp){
            WirePrinterService.print(resp.bill)
          })
        }else{
          //浏览器打印
          GuestQueue.bill({
            branch_id: guest_queue.branch_id,
            queue_setting_id: guest_queue.queue_setting_id,
            id: guest_queue.id,
            bill_type: 'html'
          }).$promise.then(function(resp){
            WirePrinterService.print_html(resp.bill)
          })
        }
      }

      function print_pre_order_bill(guest_queue){
        if(WirePrinterService.has_object()){
          //webpos打印
          bill_type = WirePrinterService.get_printer_width()
          GuestQueue.pre_order_bill({
            branch_id: guest_queue.branch_id,
            queue_setting_id: guest_queue.queue_setting_id,
            id: guest_queue.id,
            bill_type: bill_type
          }).$promise.then(function(resp){
            WirePrinterService.print(resp.bill)
          })
        }else{
          //浏览器打印
          GuestQueue.pre_order_bill({
            branch_id: guest_queue.branch_id,
            queue_setting_id: guest_queue.queue_setting_id,
            id: guest_queue.id,
            bill_type: 'html'
          }).$promise.then(function(resp){
            WirePrinterService.print_html(resp.bill)
          })
        }
      }

      function print_queue_bill_local(bill){
        WirePrinterService.print(bill)
      }

      return{
        print_queue_bill: print_queue_bill,
        print_queue_bill_local: print_queue_bill_local,
        print_pre_order_bill: print_pre_order_bill
      }
    }])