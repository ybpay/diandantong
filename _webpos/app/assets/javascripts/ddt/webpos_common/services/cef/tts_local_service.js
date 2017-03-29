WebposModules.add_service('tts_local')
angular.module('webpos.services.tts_local',[]).
  factory('TtsLocalService', ['$resource', 'WebposObjectAsyncAdapter', '$q',
    function($resource, WebposObjectAsyncAdapter, $q){
      //var object = window.TtsObject;
      //var enable = (object !== undefined);
      //function has_object(){
      //  return enable
      //}
      //
      //// params
      //// text  :string
      //// speed :int  0-100
      //// volume:int  0-100
      //function play(text, speed, volume){
      //  if(enable){
      //    var ret = object.login()
      //    if(ret == 0){
      //      return object.play(text, speed, volume)
      //    }else{
      //      return ret
      //    }
      //  }
      //}
      //
      //return {
      //  has_object: has_object,
      //  play: play
      //}

      var enable = false;
      var object = WebposObjectAsyncAdapter.create({
        obtain_service: function(){
          return window.TtsObject;
        },
        after_create: function(service){
          enable = service.has_object();
        }
      });

      function play(text, speed, volume){
        if (enable){
          return object.login().then(function(ret){
            if (ret == 0){
              return object.play(text, speed, volume);
            }else{
              return new Promise(function(resolve, reject){
                reject(ret);
              });
            }
          })
        }else{
          return new Promise(function(resolve, reject){
            reject();
          });
        }
      }

      return window.TtsLocalService = {
        has_object: object.has_object,
        play: play
      };
    }]);