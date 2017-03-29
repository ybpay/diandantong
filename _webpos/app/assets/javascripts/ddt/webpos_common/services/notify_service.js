WebposModules.add_service('notify');
angular.module('webpos.services.notify',[]).
  factory("NotifyService", ['$resource', '$rootScope', function($resource, $rootScope){

    var Notify = $resource("/private_pub/:action", {}, {
      load_config: {method: "get", params: { action: "load_config"}}
    })

    var connecting = false;
    var connected = false;

    var handlers = {}

    function set_message_handler(msg_type, handler){
      handlers[msg_type] = handler;
    }

    function remove_message_handler(msg_type){
      handlers[msg_type] = undefined;
    }

    function clear_message_handler(){
      handlers = {};
    }

    function receive_message(data, channel){
      // console.log("Receive_message")
      var msg = data.msg;
      var handler = handlers[msg.type]
      if(handler){ $rootScope.$apply(function(){handler(msg);})}
    }

    function start(){
      if(connecting){return;}
      connecting = true;
      if(!connected){
        Notify.load_config({skip_mask: true}, function(config){
          // console.log("Connecting to server")
          // console.log(config)
          PrivatePub.sign(config);
          PrivatePub.subscribe(config.channel, receive_message)
          connected = true;
          connecting = false;
        });
      }else{
        connecting = false;
      }
    }

    function clear(){
      PrivatePub.unsubscribeAll()
      clear_message_handler()
      connected = false;
      connecting = false;
    }

    function restart(){
      clear()
      start()
    }

    function set_message_hander_in_scope(scope, msg_type, handler){
      set_message_handler(msg_type, handler)
      scope.$on("$destroy", function(){
        remove_message_handler(msg_type)
      })
    }


    return {
      // start: start,
      clear: clear,
      restart: restart,
      set_message_handler: set_message_handler,
      set_message_hander_in_scope: set_message_hander_in_scope,
      remove_message_handler: remove_message_handler,
      clear_message_handler: clear_message_handler
    }
  }])
