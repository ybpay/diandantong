Ddt.factory('RefreshService', ['$interval', function($interval){
  function add(scope, action, interval){
    var refresh_interval = $interval(action, interval)
    scope.$on("$destroy", function(){
      if (angular.isDefined(refresh_interval)) {
        $interval.cancel(refresh_interval);
        refresh_interval = undefined;
      }
    })
  }

  return {
    add: add
  }
}])
