WebposModules.add_service('webpos_object_async_adapter')
angular.module('webpos.services.webpos_object_async_adapter',[]).
factory('WebposObjectAsyncAdapter', ['$q', function($q){

  function toPromiseResult(result){
    if (result instanceof Promise) {
      return result
    } else {
      return new Promise(function (resolve, reject) {
        resolve(result)
      });
    }
  }

  function toPromiseFunc(object, func){
    if (typeof func == 'function') {
      return function () {
        var result = func.apply(object, arguments)
        return toPromiseResult(result);
      }
    } else {
      return func
    }
  }

  var exports = function(webposObject){
    this.has_object = function(){
      return webposObject != undefined
    }
    this.if_enable = function(methodName, closure){
      if (typeof methodName == 'function'){
        closure = methodName
        methodName = undefined
      }

      var enable;
      if (methodName){
        enable = this.has_object() && this[methodName]
      }else{
        enable = this.has_object()
      }

      if (enable && closure){
        return toPromiseResult(closure.call())
      } else {
        return $q(function(resolve, reject){
          if (enable){
            resolve()
          }else{
            reject()
          }
        });
      }
    }

    if (webposObject != undefined){
      for (var methodName in webposObject) {
        this[methodName] = toPromiseFunc(webposObject, webposObject[methodName])
      }
    }

    this._export = function(methodName){
      var method = this[methodName]
      if (!method){
        this[methodName] = function(){
          return $q(function(resolve, reject){
            reject()
          })
        }
      }
    }
  }

  exports.create = function(options){
    var apiService = options.obtain_service()
    if (apiService){
      var service = new exports(apiService);
      if (options.after_create) {
        options.after_create(service);
      }
      return service;
    } else {
      var service = new exports()
      if (options.after_create) {
        options.after_create(service);
      }

      window.addEventListener("message", function(event){
        if (event.source != window) {
          var data = event.data
          if (data.type == 'initWebposApi'){
            var apiService = options.obtain_service()
            if (apiService){
              console.info("recv message for webpos api refresh", apiService)
              var attrs = new exports(apiService)
              angular.extend(service, attrs)
              if (options.after_create) {
                options.after_create(service);
              }
            }
          }
        }
      })
      return service;
    }
  }

  return exports;

}]);
