WebposModules.add_service('customer_display')
angular.module('webpos.services.customer_display',[]).
  factory('CustomerDisplayService', ['$resource', 'WebposObjectAsyncAdapter',
    function($resource, WebposObjectAsyncAdapter){
      //var object = window.CustomerDisplayObject;
      //var enable = (object !== undefined);
      //function has_object(){
      //  return enable
      //}

      var object = WebposObjectAsyncAdapter.create({
        obtain_service: function(){
          return window.CustomerDisplayObject;
        }
      });

      // port_name 端口名称 ["COM1", "COM2", "COM3", "COM4", "COM5"]
      // baud_rate 通信波特率 [2400, 4800, 9600]
      function get_port_name(){ return object.port_name; }
      function get_baud_rate(){ return object.baud_rate; }

      function set_info(_port_name, _baud_rate){
        return object.if_enable(function(){
          return object.set_info(_port_name, _baud_rate)
        });
      }

      function display_data(display_type, data){
        return object.if_enable(function(){
          // display_type 显示名称 { 0: 清屏 1: 单价 2: 合计 3: 收款 4: 找零}
          // data 显示数据 "10.00"
          return object.display_data(display_type, data)
        });
      }

      return window.CustomerDisplayService = {
        has_object: object.has_object,
        get_port_name: get_port_name,
        get_baud_rate: get_baud_rate,
        set_info: set_info,
        display_data: display_data
      }
    }]);