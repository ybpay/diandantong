WebposModules.add_directive('wp_link')
angular.module('webpos.directives.wp_link', [])
  .directive('wpLink', ['$rootScope', 'BrowserFormService',
    function ($rootScope, BrowserFormService) {
      return {
        restrict: 'EA',
        replace: true,
        transclude: true,
        template: '<a ng-transclude></a>',
        link: function(scope, element, attrs){
          if (BrowserFormService.has_object()){
            var url = attrs.href;
            var target = attrs.target;
            if (target == '_blank') {
              element.on("click", function () {
                BrowserFormService.open_in_browser(url);
                return false;
              });
            }
          }
        }
      }
    }])
