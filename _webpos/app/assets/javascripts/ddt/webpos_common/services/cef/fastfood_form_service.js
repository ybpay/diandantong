WebposModules.add_service('fastfood_form')
angular.module('webpos.services.fastfood_form', []).factory('FastfoodFormService', ['$rootScope', 'WebposObjectAsyncAdapter',
  function ($rootScope, WebposObjectAsyncAdapter) {

    var object = WebposObjectAsyncAdapter.create({
      obtain_service: function () {
        return window.FastfoodFormObject;
      }
    });

    function has_object() {
      return object.has_object()
    }

    function get_images_path() {
      return object.if_enable(function () {
        return object.get_images_path();
      });
    }

    function set_images_path(path) {
      return object.if_enable(function () {
        return object.set_images_path(path);
      });
    }

    function get_images_files() {
      return object.if_enable(function () {
        return object.get_images_files();
      });
    }

    function get_images_data_uris() {
      return object.if_enable(function () {
        return object.get_images_data_uris();
      });
    }

    function set_images_interval(interval){
      return object.if_enable(function(){
        object.set_images_interval(interval);
      });
    }

    function get_images_interval(){
      return new Promise(function(resolve, reject){
        return object.if_enable(function(){
          return object.get_images_interval().then(function(result){
            resolve(result);
          });
        }).catch(function(){
          resolve(3000);
        });
      });
    }

    return {
      has_object: has_object,
      get_images_path: get_images_path,
      set_images_path: set_images_path,
      get_images_files: get_images_files,
      get_images_data_uris: get_images_data_uris,
      set_images_interval: set_images_interval,
      get_images_interval: get_images_interval
    }
  }]);
