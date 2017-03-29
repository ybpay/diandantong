WebposModules.add_service('box')
angular.module('webpos.services.box', []).
  factory('Box', ["$rootScope", "$timeout", function($rootScope, $timeout){
    $rootScope.confirm_modal = { show: false };
    $rootScope.alert_toast = {show: false};
    return {
      alert: alert,
      confirm: confirm,
      lock_confirm_modal: lock_confirm_modal
    }

    function lock_confirm_modal(){
      $rootScope.confirm_modal.lock_mask = true
    }

    function confirm(info, ok_callback, ok_text, cancel_callback, cancel_text){
      info = (angular.isArray(info) ? info.join("<br/>") : info);
      $rootScope.confirm_modal = {
        info         : info,
        ok           : function(){ $rootScope.confirm_modal.show = false; if(ok_callback){ ok_callback() };},
        ok_text      : ok_text || "确定",
        cancel       : function(){ $rootScope.confirm_modal.show = false; if(cancel_callback){ cancel_callback() };},
        cancel_text  : cancel_text || "取消",
        show         : true
      }
    }

    function alert(info, time){
      info = (angular.isArray(info) ? info.join("<br/>") : info);
      if($rootScope.alert_toast.timer){ $timeout.cancel($rootScope.alert_toast.timer); }
      var timer = $timeout(function(){
        $rootScope.alert_toast.show = false;
      }, time || 3000);
      $rootScope.alert_toast = {
        info         : info,
        show         : true
      }
    }

  }])