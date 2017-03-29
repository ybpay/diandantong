angular.module('ddt_app.directives.include-replace', []).directive('includeReplace', ['$compile', function ($compile) {
  return {
    require: 'ngInclude',
    restrict: 'A',
    link: function (scope, el, attrs) {
      el.replaceWith(el.children());
    }
  }
}]);