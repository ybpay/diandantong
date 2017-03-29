WebposModules.add_service('flash_player')
angular.module('webpos.services.flash_player',[]).
  factory('FlashPlayerService', ['$resource',
    function($resource){
      // http://flash-mp3-player.net/players/js/preview/
      // flash_listener
      var object = document.getElementById("my-flash");

      function play(url, count, callback){
        if(typeof count === undefined){ count = 1}
        object.SetVariable("method:stop", "");
        object.SetVariable("method:setUrl", url);
        object.SetVariable("method:play", "");
        object.SetVariable("enabled", "true");
        flash_listener.onUpdate = function(){
          // console.log(this.duration + " : " + this.position)
          if(this.position == 0){
            count --;
            if(count > 0){
              object.SetVariable("method:stop", "");
              object.SetVariable("method:play", "");
            }else{
              object.SetVariable("method:stop", "");
              object.SetVariable("enabled", "false");
              if(callback){callback()}
            }
          }
        }
      }

      function pause(){ object.SetVariable("method:pause", ""); }
      function stop(){ object.SetVariable("method:stop", ""); }
      function set_position(position){ object.SetVariable("method:setPosition", position); }

      return {
        play: play
      }
    }]);