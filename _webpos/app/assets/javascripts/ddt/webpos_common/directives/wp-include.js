// include contents from src and replace origin element
// CAUTION:
// 1. No Watcher, so change srcExp won't lead to change content
// 2. it would ignore all attribute on origin element
//
WebposModules.add_directive('wp-include')
angular.module('webpos.directives.wp-include', [])
  .directive('wpInclude', ['$parse', '$animate', 'TemplateService',
    function ($parse, $animate, TemplateService) {
      return {
        restrict: 'ECA',
        priority: 400,
        terminal: true,
        transclude: 'element',
        controller: angular.noop,
        compile: function (element, attr) {
          var srcExp = attr.wpInclude || attr.src;
          var srcGetter = $parse(srcExp)

          var wpIncludeStartComment = document.createComment(' wpInclude: ' + srcExp + ' ')
          var wpIncludeEndComment = document.createComment(' end wpInclude: ' + srcExp + ' ')

          return function wpIncludeLink(scope, element, attr, ctrl) {
            var src = srcGetter(scope)
            var linkFn = TemplateService.getLinkFn(src)

            var currentScope;
            if (currentScope){
              currentScope.$destroy();
            }
            currentScope = scope.$new()

            linkFn(currentScope, function(clone, scope){
              var startNode = wpIncludeStartComment.cloneNode(false)
              var endNode = wpIncludeEndComment.cloneNode(false)
              var nodes = [startNode]
              nodes = nodes.concat(clone)
              nodes.push(endNode)

              //element.empty()
              //if (replace == "true") {
              //  element.replaceWith(nodes);
              //} else {
              $animate.enter(nodes, null, element);
              //}
            });
          }
        }
      }
    }]);