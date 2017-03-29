WebposModules.add_directive('include-replace')
angular.module('webpos.directives.include-replace', []).directive('includeReplace', function () {
  return {
    require: 'ngInclude',
    restrict: 'A',
    link: function (scope, el, attrs) {
      el.replaceWith(el.children());
    }
  }
});