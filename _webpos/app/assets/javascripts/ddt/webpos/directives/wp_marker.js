WebposModules.add_directive('wp_marker')
angular.module('webpos.directives.wp_marker', [])
  .directive("wpMarker",["$rootScope",
    function($rootScope){
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        marked: "=",
        onMarked: "&",
        onUnmark: "&"
      },
      template: '<div class="wp-marker" mk="true" ng-click="click_marker(); return;">'+
                  "<div class='circle' mk='true'></div>"+
                '</div>',
      link: function(scope, element, attrs){

        scope.click_marker = function(){
          scope.marked = !scope.marked;
          scope.marked ? scope.onMarked() : scope.onUnmark();
        }

        var clear_watch_marked = scope.$watch("marked", function(newValue, oldValue){
          var className = newValue ? "circle selected" : "circle"
          $(element[0].firstChild).attr("class", className)
        })
        scope.$on("$destroy", function(){
          clear_watch_marked()
        })
      }
    }
  }])