//WebposModules.add_directive('wp_cache')
//angular.module('webpos.directives.wp_cache', [])
//  .directive('wpCache', ['$compile', '$animate', '$cacheFactory', '$parse',
//    function ($compile, $animate, $cacheFactory, $parse) {
//      return {
//        priority: 2000,
//        transclude: true,
//        restrict: 'A',
//        compile: function wpCacheCompile($element, $attr){
//
//          var elementCache = $cacheFactory.get("wp-element-cache");
//          if (!elementCache){
//            elementCache = $cacheFactory("wp-element-cache");
//          }
//
//          // initialize work
//          var cacheKeyExp = $attr.wpCache
//          //var cacheKeyGetter = $parse(cacheKeyExp);
//
//          return function wpCacheLink($scope, $element, $attr, ctrl, $transclude){
//
//            $scope.$watch(cacheKeyExp, function(cacheKey){
//              var elems = elementCache.get(cacheKey);
//              if (elems) {
//                console.info("wp cache hit: " + cacheKey)
//                $animate.enter(elems, $element)
//              } else {
//                console.info("wp cache miss: " + cacheKey)
//                $transclude(function wpCacheTransclude(clone, scope){
//                  $element.empty();
//                  $animate.enter(clone, $element)
//                  elementCache.put(cacheKey, clone)
//                });
//              }
//            });
//          }
//        }
//      }
//    }]);