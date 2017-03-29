WebposModules.add_directive('wp_view')
angular.module('webpos.directives.wp_view', [])
  .directive('wpView', ['$route', '$anchorScroll', '$animate',
    function wpViewFactory($route, $anchorScroll, $animate) {
      return {
        restrict: 'ECA',
        terminal: true,
        priority: 400,
        transclude: 'element',
        link: function (scope, $element, attr, ctrl, $transclude) {
          var currentScope,
            currentElement,
            previousLeaveAnimation,
            autoScrollExp = attr.autoscroll,
            onloadExp = attr.onload || '';

          scope.$on('$routeChangeSuccess', update);
          update();

          function cleanupLastView() {
            if (previousLeaveAnimation) {
              $animate.cancel(previousLeaveAnimation);
              previousLeaveAnimation = null;
            }

            if (currentScope) {
              currentScope.$destroy();
              currentScope = null;
            }
            if (currentElement) {
              previousLeaveAnimation = $animate.leave(currentElement);
              previousLeaveAnimation.then(function () {
                previousLeaveAnimation = null;
              });
              currentElement = null;
            }
          }

          function update() {
            var locals = $route.current && $route.current.locals,
              template = locals && locals.$template;

            if (angular.isDefined(template)) {
              var newScope = scope.$new();
              var current = $route.current;

              // Note: This will also link all children of ng-view that were contained in the original
              // html. If that content contains controllers, ... they could pollute/change the scope.
              // However, using ng-view on an element with additional content does not make sense...
              // Note: We can't remove them in the cloneAttchFn of $transclude as that
              // function is called before linking the content, which would apply child
              // directives to non existing elements.
              var clone = $transclude(newScope, function (clone) {
                $animate.enter(clone, null, currentElement || $element).then(function onNgViewEnter() {
                  if (angular.isDefined(autoScrollExp)
                    && (!autoScrollExp || scope.$eval(autoScrollExp))) {
                    $anchorScroll();
                  }
                });
                cleanupLastView();
              });

              currentElement = clone;
              currentScope = current.scope = newScope;
              currentScope.$emit('$viewContentLoaded');
              currentScope.$eval(onloadExp);
            } else {
              cleanupLastView();
            }
          }
        }
      };
    }
  ])
  // This directive is called during the $transclude call of the first `ngView` directive.
  // It will replace and compile the content of the element with the loaded template.
  // We need this directive so that the element content is already filled when
  // the link function of another directive on the same element as ngView
  // is called.
  .directive('wpView', ['$compile', '$controller', '$route', 'TemplateService',
    function wpViewFillContentFactory($compile, $controller, $route, TemplateService) {
      return {
        restrict: 'ECA',
        priority: -400,
        link: function (scope, $element) {
          var current = $route.current,
            locals = current.locals;

          var link
          var precompiledTemplateUrl = locals.$template.templateUrl;
          if (!precompiledTemplateUrl){
            $element.html(locals.$template);
            link = $compile($element.contents());
          } else {
            link = TemplateService.getLinkFn(precompiledTemplateUrl)
          }

          if (current.controller) {
            locals.$scope = scope;
            var controller = $controller(current.controller, locals);
            if (current.controllerAs) {
              scope[current.controllerAs] = controller;
            }
            $element.data('$ngControllerController', controller);
            $element.children().data('$ngControllerController', controller);
          }

          if (!precompiledTemplateUrl) {
            link(scope);
          } else {
            link(scope, function(clone, scope){
              $element.html(clone)
            })
          }
        }
      };
    }])
