WebposModules.add_service('title_scroll')
angular.module('webpos.services.title_scroll', []).
  factory('TitleScrollService', ['$interval', function($interval){
    var interval = undefined;
    var delay = 200

    function set(title){
      cancel()
      function scroll_title() {
        window.document.title = title
        title = title.substring(1, title.length) + title.substring(0,1)
      }
      interval = $interval(scroll_title, delay)
    }

    function cancel(){
      window.document.title = "云餐厅收银系统"
      if (angular.isDefined(interval)) {
        $interval.cancel(interval);
        interval = undefined;
      }
    }

    return {
      set: set,
      cancel: cancel
    }
  }])
