WebposModules.add_directive('wp_table_row')
angular.module('webpos.directives.wp_table_row', [])
  .directive('wpTableRow', [function () {
    return {
      restrict: 'EA',
      transclude: true,
      replace: true,
      template: '<div class="wp-table-row" ng-transclude></div>',
      link: function(scope, element, attrs){
      }
    }
  }]).directive('wpTableCol', [function() {
    return {
      restrict: 'EA',
      transclude: true,
      replace: true,
      template: '<div class="wp-table-row"><div class="wp-table-col" ng-transclude></div></div>',
      link: function(scope, element, attrs){
      }
    }
  }])