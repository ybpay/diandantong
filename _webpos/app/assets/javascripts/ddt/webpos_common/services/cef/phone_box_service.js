window.PhoneBox = {
  caller: function(number){}
}
WebposModules.add_service('phone_box')
angular.module('webpos.services.phone_box',[]).
  factory('PhoneBoxService', ['$rootScope',
    function($rootScope){

      var onCallHandler;

      var callbackDelegate = function(number){
        console.info("on phone call: " + number)
        if (onCallHandler) {
          onCallHandler(number)
        }
      }

      // backward compatible
      if (PhoneBox) {
        PhoneBox.caller = callbackDelegate
      }

      window.addEventListener("message", function(event) {
        var message = event.data
        if (message.type == 'webpos:phonebox:call'){
          var number = message.number;
          callbackDelegate(number)
        }
      }, false);


      function caller(callback){
        onCallHandler = callback;
      }

      return {
        caller: caller
      }
    }]);