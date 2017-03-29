WebposModules.add_service('print')
angular.module('webpos.services.print',[]).
  factory('PrintService',['WirePrinterService', 'BaseOrderService', 'GuestQueueService', 'TableService',
    function(WirePrinterService, BaseOrderService, GuestQueueService, TableService){
      function print_consume_bill_from_table(branch_id, table_id){
        if(WirePrinterService.has_object()){
          TableService.resource.get_consume_bill({ branch_id: branch_id, id: table_id, bill_type: WirePrinterService.get_order_bill_type()},
            function(resp){
              WirePrinterService.print(resp.bill)
            });
        }
      }

      function print_consume_bill(order){
        if(WirePrinterService.has_object()){
          //webpos打印
          BaseOrderService.bill(order.type_str, order.branch_id, order.id, WirePrinterService.get_order_bill_type(),
            {is_consume_bill: true},
            function(resp){
              WirePrinterService.print(resp.bill)
            });
        }else{
          //浏览器打印
          // BaseOrderService.bill(order.type_str, order.branch_id, order.id, 'html',
          //   {is_consume_bill: true},
          //   function(resp){
          //     var bill = resp.bill;
          //     bill += "<br /><br /><br />"
          //     print_html(bill)
          //   });
        }
      }

      function print_product_bill(order){
        if(WirePrinterService.has_object()){
          //webpos打印
          BaseOrderService.bill(order.type_str, order.branch_id, order.id, WirePrinterService.get_order_bill_type(),
            {is_product_bill: true},
            function(resp){
              // console.log(resp.bill)
              WirePrinterService.print(resp.bill)
            });
        }else{
          //浏览器打印
          BaseOrderService.bill(order.type_str, order.branch_id, order.id, 'html',
            {is_product_bill: true},
            function(resp){
              // console.log(resp.bill)
              var bill = resp.bill;
              bill += "<br /><br /><br />"
              WirePrinterService.print_html(bill)
            });
        }
      }

      function print_last_append_product_bill(order){
        if(WirePrinterService.has_object()){
          //webpos打印
          BaseOrderService.bill(order.type_str, order.branch_id, order.id, WirePrinterService.get_order_bill_type(),
            {is_last_append_product_bill: true},
            function(resp){
              WirePrinterService.print(resp.bill)
            });
        }else{
          //浏览器打印
          BaseOrderService.bill(order.type_str, order.branch_id, order.id, 'html',
            {is_last_append_product_bill: true},
            function(resp){
              // console.log(resp.bill)
              var bill = resp.bill;
              bill += "<br /><br /><br />"
              WirePrinterService.print_html(bill)
            });
        }
      }

      function print_order_bill(order, addition_infos, options){
        if(WirePrinterService.has_object()){
          //webpos打印
          return BaseOrderService.bill(order.type_str, order.branch_id, order.id, WirePrinterService.get_order_bill_type(), options || {}, function(resp){
            if(angular.isArray(resp.bill)){
              angular.forEach(resp.bill, function(bill){
                WirePrinterService.print(bill, WirePrinterService.get_printer_times())
              })
            }else{
              var bill = resp.bill
              if(addition_infos){
                bill += addition_infos.join("\n")
              }
              bill += "\n\n\n"
              WirePrinterService.print(bill, WirePrinterService.get_printer_times())
            }
          })
        }else{
          //浏览器打印
          return BaseOrderService.bill(order.type_str, order.branch_id, order.id, 'html', options || {}, function(resp){
            var bill = resp.bill
            if(addition_infos){
              bill += addition_infos.join('<br/>')
            }
            bill += "<br /><br /><br />"
            WirePrinterService.print_html(bill)
          })
        }
      }

      function print_order_bill_local(bill, print_one_time){
        var n = print_one_time ? 1 : WirePrinterService.get_printer_times()
        if(angular.isArray(bill)){
          angular.forEach(bill, function(b){
            WirePrinterService.print(b, n)
          })
        }else{
          WirePrinterService.print(bill, n)
        }
      }

      function print_queue_bill_local(bill){
        WirePrinterService.print(bill)
      }

      function print_queue_bill(guest_queue){
        if(WirePrinterService.has_object()){
          //webpos打印
          bill_type = WirePrinterService.get_printer_width()
          GuestQueueService.bill(guest_queue.branch_id, guest_queue.queue_setting_id, guest_queue.id, bill_type, function(resp){
            WirePrinterService.print(resp.bill)
          })
        }else{
          //浏览器打印
          GuestQueueService.bill(guest_queue.branch_id, guest_queue.queue_setting_id, guest_queue.id, 'html', function(resp){
            WirePrinterService.print_html(resp.bill)
          })
        }
      }

      function print_pre_order_bill(guest_queue){
        if(WirePrinterService.has_object()){
          //webpos打印
          bill_type = WirePrinterService.get_printer_width()
          GuestQueueService.pre_order_bill(guest_queue.branch_id, guest_queue.queue_setting_id, guest_queue.id, bill_type, function(resp){
            WirePrinterService.print(resp.bill)
          })
        }else{
          //浏览器打印
          GuestQueueService.pre_order_bill(guest_queue.branch_id, guest_queue.queue_setting_id, guest_queue.id, 'html', function(resp){
            WirePrinterService.print_html(resp.bill)
          })
        }
      }

      return{
        print_order_bill: print_order_bill,
        print_product_bill: print_product_bill,
        print_consume_bill_from_table: print_consume_bill_from_table,
        print_consume_bill: print_consume_bill,
        print_queue_bill: print_queue_bill,
        print_queue_bill_local: print_queue_bill_local,
        print_order_bill_local: print_order_bill_local,
        print_pre_order_bill: print_pre_order_bill,
        print_last_append_product_bill: print_last_append_product_bill,
      }
    }])