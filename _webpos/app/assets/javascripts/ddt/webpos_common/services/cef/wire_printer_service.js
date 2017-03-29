WebposModules.add_service('wire_printer')
angular.module('webpos.services.wire_printer',[]).
  factory('WirePrinterService', ['$rootScope', '$resource', 'WebposObjectAsyncAdapter',
    function($rootScope, $resource, WebposObjectAsyncAdapter){
      //var printer = window.WirePrinterObject
      var printer = WebposObjectAsyncAdapter.create({
        obtain_service: function(){
          return window.WirePrinterObject;
        },
        after_create: function(service){
          $rootScope.is_cef = service.has_object()
        }
      });

      function has_object(){
        return printer.has_object()
      }
      //function get_printer_names(){     if(has_object()){ return printer.get_printer_names()  }}
      function get_printer_names(){
        return printer.if_enable(function(){
          return printer.get_printer_names();
        });
      }
      function get_printer_com_ports(){
        return printer.if_enable(function(){
          return printer.get_printer_com_ports();
        });
      }
      function get_printer_name(){      if(has_object()){ return printer.printer_name }}
      function get_printer_width(){     if(has_object()){ return printer.printer_width }}
      function get_printer_times(){     if(has_object()){ return printer.printer_times }}
      function get_printer_type(){      if(has_object()){ return printer.printer_type }}
      function get_printer_net_port(){  if(has_object()){ return printer.printer_net_port }}
      function get_printer_com_port(){  if(has_object()){ return printer.printer_com_port }}
      function get_printer_baud_rate(){ if(has_object()){ return printer.printer_baud_rate }}
      function get_printer_lpt_port(){  if(has_object()){ return printer.printer_lpt_port }}
      function set_printer_info(type, name, width, net_port, com_port, baud_rate, lpt_port, times) {
        return printer.if_enable(function () {
          printer.printer_type = type
          printer.printer_name = name
          printer.printer_width = width
          printer.printer_net_port = net_port
          printer.printer_com_port = com_port
          printer.printer_baud_rate = baud_rate
          printer.printer_lpt_port = lpt_port
          printer.printer_times = times
          printer.set_printer_info(type, name, width, net_port, com_port, baud_rate, lpt_port, times);
        });
      }

      function is_manual_print(){
        return new Promise(function(resolve, reject){
          return printer.if_enable("is_manual_print").then(function(){
            printer.is_manual_print().then(function(result){
              resolve(result)
            }).catch(function(err){
              reject(err)
            });
          }).catch(function(){
            if(get_ddb_cache("current_printer_manual_print") == null){
              set_ddb_cache("current_printer_manual_print", false)
              resolve(false)
            }else{
              resolve(get_ddb_cache("current_printer_manual_print"))
            }
          });
        });
      }

      function set_manual_print(flag){
        return new Promise(function(resolve){
          return printer.if_enable("set_manual_print").then(function(){
            return printer.set_manual_print(flag);
          }).catch(function(){
            set_ddb_cache("current_printer_manual_print", flag)
            resolve()
          });
        });
      }

      function is_config(){
        try{
          switch(printer.printer_type){
          case "driven":
            return printer.printer_name != undefined && printer.printer_name != null && printer.printer_name != ""
            break;
          case "net":
            return printer.printer_net_port != undefined && printer.printer_net_port != null && printer.printer_net_port != ""
            break;
          case "com":
            return printer.printer_com_port != undefined && printer.printer_com_port != null && printer.printer_com_port != ""
            break;
          case "lpt":
            return printer.printer_lpt_port != undefined && printer.printer_lpt_port != null && printer.printer_lpt_port != ""
            break;
          default:
            return printer.printer_name != undefined && printer.printer_name != null && printer.printer_name != ""
            break;
          }
        } catch (e) {
          return printer.printer_name != undefined && printer.printer_name != null && printer.printer_name != ""
        }
      }

      function get_order_bill_type(){
        var printer_width = printer.printer_width
        if(printer_width == 58 || printer_width == 80){
          return printer_width
        }else if(printer_width == 60){
          return 'label'
        }
      }

      function print_consume_bill(order){
        if(has_object()){
          //webpos打印
          BaseOrderService.bill(order.type_str, order.branch_id, order.id, get_order_bill_type(),
            {is_consume_bill: true},
            function(resp){
              print(resp.bill)
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
        if(has_object()){
          //webpos打印
          BaseOrderService.bill(order.type_str, order.branch_id, order.id, get_order_bill_type(),
            {is_product_bill: true},
            function(resp){
              // console.log(resp.bill)
              print(resp.bill)
            });
        }else{
          //浏览器打印
          BaseOrderService.bill(order.type_str, order.branch_id, order.id, 'html',
            {is_product_bill: true},
            function(resp){
              // console.log(resp.bill)
              var bill = resp.bill;
              bill += "<br /><br /><br />"
              print_html(bill)
            });
        }
      }

      function print_last_append_product_bill(order){
        if(has_object()){
          //webpos打印
          BaseOrderService.bill(order.type_str, order.branch_id, order.id, get_order_bill_type(),
            {is_last_append_product_bill: true},
            function(resp){
              // console.log(resp.bill)
              print(resp.bill)
            });
        }else{
          //浏览器打印
          BaseOrderService.bill(order.type_str, order.branch_id, order.id, 'html',
            {is_last_append_product_bill: true},
            function(resp){
              // console.log(resp.bill)
              var bill = resp.bill;
              bill += "<br /><br /><br />"
              print_html(bill)
            });
        }
      }

      function print_order_bill(order, addition_infos, options){
        if(has_object()){
          //webpos打印
          if(order.bill){
            print(order.bill, get_printer_times())
          }else{
            BaseOrderService.bill(order.type_str, order.branch_id, order.id, get_order_bill_type(), options || {}, function(resp){
              if(angular.isArray(resp.bill)){
                angular.forEach(resp.bill, function(bill){
                  print(bill, get_printer_times())
                })
              }else{
                var bill = resp.bill
                if(addition_infos){
                  bill += addition_infos.join("\n")
                }
                bill += "\n\n\n"
                print(bill, get_printer_times())
              }
            })
          }
        }else{
          //浏览器打印
          BaseOrderService.bill(order.type_str, order.branch_id, order.id, 'html', options || {}, function(resp){
            var bill = resp.bill
            if(addition_infos){
              bill += addition_infos.join('<br/>')
            }
            bill += "<br /><br /><br />"
            print_html(bill)
          })
        }
      }

      function print_order_bill_local(bill, print_one_time){
        var n = print_one_time ? 1 : get_printer_times()
        if(angular.isArray(bill)){
          angular.forEach(bill, function(b){
            print(b, n)
          })
        }else{
          print(bill, n)
        }
      }

      function print_queue_bill_local(bill){
        print(bill)
      }

      function print_queue_bill(guest_queue){
        if(has_object()){
          //webpos打印
          bill_type = printer.printer_width
          GuestQueueService.bill(guest_queue.branch_id, guest_queue.queue_setting_id, guest_queue.id, bill_type, function(resp){
            print(resp.bill)
          })
        }else{
          //浏览器打印
          GuestQueueService.bill(guest_queue.branch_id, guest_queue.queue_setting_id, guest_queue.id, 'html', function(resp){
            print_html(resp.bill)
          })
        }
      }

      function print_pre_order_bill(guest_queue){
        if(has_object()){
          //webpos打印
          bill_type = printer.printer_width
          GuestQueueService.pre_order_bill(guest_queue.branch_id, guest_queue.queue_setting_id, guest_queue.id, bill_type, function(resp){
            print(resp.bill)
          })
        }else{
          //浏览器打印
          GuestQueueService.pre_order_bill(guest_queue.branch_id, guest_queue.queue_setting_id, guest_queue.id, 'html', function(resp){
            print_html(resp.bill)
          })
        }
      }

      function print(content, times){
        if(has_object()){
          times = typeof times == 'undefined' ? 1 : times
          content = content||"";
          content = content.replace(/<br\/>/g, "\n")
          content = content.replace(/&nbsp;/g, " ")
          content = content.replace(/&ensp;/g, " ")
          printer.print(content, times)
        }else{
          print_html(content)
        }
      }

      function open_cashbox(){
        if(has_object()){
          try {
            printer.open_cashbox()
          } catch (e) {
          }
        }
      }

      function print_html(content){
        var myWindow = window.open();
        if (myWindow) {
          myWindow.document.write('<html><head><style type="text/css" media="all">body { background: white;font-family:"SimHei";font-size: 8pt;} </style></head><body>');
          myWindow.document.write(content + "<br/>");
          myWindow.document.write('</body></html>');
          myWindow.document.close();
          myWindow.focus();
          myWindow.print();
          myWindow.close();
        } else {
            alert('弹窗被拦截，请允许弹出打印窗口。')
        }
      }

      function is_new_cef_version(){
        try {
          printer.get_printer_com_ports()
          return true
        } catch (e) {
          return false
        }
      }

      return window.WirePrinterService = {
        is_new_cef_version: is_new_cef_version,
        has_object: has_object,
        get_printer_names:get_printer_names,
        get_printer_com_ports:get_printer_com_ports,
        get_printer_name:get_printer_name,
        get_printer_width:get_printer_width,
        get_printer_times:get_printer_times,
        get_printer_type:get_printer_type,
        get_printer_net_port:get_printer_net_port,
        get_printer_com_port:get_printer_com_port,
        get_printer_baud_rate:get_printer_baud_rate,
        get_printer_lpt_port:get_printer_lpt_port,
        get_order_bill_type:get_order_bill_type,
        set_printer_info:set_printer_info,
        is_config: is_config,
        print: print,
        print_html: print_html,
        open_cashbox: open_cashbox,
        is_manual_print: is_manual_print,
        set_manual_print: set_manual_print
      }
    }]);
