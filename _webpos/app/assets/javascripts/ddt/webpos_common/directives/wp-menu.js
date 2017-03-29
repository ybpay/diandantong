WebposModules.add_directive('wp_menu')
angular.module('webpos.directives.wp_menu', [])
  .directive('wpMenu', ['$rootScope',
    function ($rootScope) {
    return {
      restrict: 'EA',
      scope: {
        icon: "@"
      },
      replace: true,
      transclude: true,
      template: '<div class="wp-menu">'
                + '<i class="wp-menu-icon fa fa-{{icon}} fa-fw"></i>'
                + '<div class="wp-menu-text" ng-transclude></div>'
              + '</div>',
      link: function(scope, element, attrs){
      }
    }
  }])
