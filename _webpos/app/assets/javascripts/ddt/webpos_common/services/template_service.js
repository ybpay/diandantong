WebposModules.add_service('template')
angular.module('webpos.services.template', []).
factory('TemplateService', ['$window', '$templateCache', '$cacheFactory', '$compile',
  function($window, $templateCache, $cacheFactory, $compile){

    /*
    initialize linkFn cache.
    when a url is requested, it fetch from templateCache and compiled it to link function.
     */
    var linkFnCache = $cacheFactory("wp-link-function");

    var templatePathPrefixLength = "templates".length
    for(var fileName in $window.JST) {
      var cacheUrl = fileName.substr(templatePathPrefixLength) + ".html"
      var contentFunc = $window.JST[fileName]
      contentFunc.templateUrl = cacheUrl
      if (cacheUrl.indexOf('_directives') != -1){
        $templateCache.put(cacheUrl, contentFunc())
      }else {
        $templateCache.put(cacheUrl, contentFunc)
      }
    }

  return {
    getLinkFn: function(key){
      var linkFn = linkFnCache.get(key)
      if (!linkFn){
        // try to get from template cache
        var tp = $templateCache.get(key)
        if (tp){
          if (typeof tp == 'function') {
            tp = tp()
          }
          linkFn = $compile(tp)
          linkFnCache.put(key, linkFn)
        } else {
          throw new Error(_.template("missing template for key[${key}]")({
            url: key
          }))
        }
      }
      return linkFn;
    },

    registerTemplate: function(key, template) {
      $templateCache.put(key, template)
    }
  }
}])