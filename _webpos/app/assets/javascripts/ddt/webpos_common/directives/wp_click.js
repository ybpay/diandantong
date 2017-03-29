WebposModules.add_directive('wp_click')
angular.module('webpos.directives.wp_click', [])
 .directive('wpClick', ['$parse','$compile', function($parse, $compile) {
  return {
    restrict: 'A',
    compile : function(tElement, tAttrs, transclude) {
      // Example
      // <div wp-click="submit()" wp-click-interval="10"></div>
      tElement.attr('ng-click', 'wpClick($event)');
      tElement.removeAttr('wp-click');
      var fn = $parse(tAttrs['wpClick']);
      var wp_interval = parseInt(tAttrs['wpClickInterval']) || 5;
      return {
        pre : function(scope, iElement, iAttrs, controller) {
          scope.wp_click_time = 0;
          scope.wpClick = function(event) {
            var now = Date.now()
            var interval = now - scope.wp_click_time
            if(interval < wp_interval * 1000){
              console.log('click interval: ' + interval + "/" + wp_interval * 1000);
            }else{
              scope.wp_click_time = now;
              // console.log('wpClick.before');
              fn(scope, {$event:event});
              // console.log('wpClick.after');
            }
          };
          $("div[ng-transclude]", iElement).removeAttr("ng-transclude")
          $compile(iElement)(scope);
        },
        post : function postLink(scope, iElement, iAttrs, controller) {
        }
      };
    },
    scope : true
  };
}]);