WebposModules.add_service('browser_form')
angular.module('webpos.services.browser_form',[]).
factory('BrowserFormService', ['$rootScope', 'WebposObjectAsyncAdapter',
  function($rootScope, WebposObjectAsyncAdapter){

    function obtaion_service(){
      // for nw
      var browserFormObject = window.BrowserFormObject;

      // for .net
      if (browserFormObject == undefined){
        //
        // sync interface:
        //
        // get_title
        // set_title
        // get_host
        // set_host
        // is_full_screen
        //
        browserFormObject = window.BrowerFormObject
      }
      return browserFormObject;
    }

    //
    // 如果要明确化接口定义,可以使用以下方式.
    // 但实际上由于历史版本原因,不是很一个收银端都支持以下函数
    //
    //return {
    //  get_title:          service.get_title,
    //  set_title:          service.set_title,
    //  get_host:           service.get_host,
    //  set_host:           service.set_host,
    //
    //  // .net 1.1.22+
    //  set_url:            service.set_url,
    //  set_path:           service.set_path,
    //  reload:             service.reload,
    //
    //  // nw
    //  set_color:          service.set_color
    //  reload
    //}

    var s = WebposObjectAsyncAdapter.create({
      obtain_service: obtaion_service,
      after_create: function(service){
        service._export("get_title");
        service._export("set_title");
        service._export("set_color");
        service._export("reset_color");
        service._export("notify_conn_error");
        // funcion: set_system_datetime
        // since:   2.5.4
        // example: set_system_datetime("2016-08-30 12:04:10");
        service._export("set_system_datetime");
        service._export("open_in_browser"); // function(url, browser='chrome'){}
      }
    });

    return s;
  }]);