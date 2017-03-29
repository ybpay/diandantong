WebposModules.add_service('verify_vip_info')
angular.module('webpos.services.verify_vip_info', []).
  factory("VerifyVipInfoService", ['$rootScope', '$resource', 'NotifyService',
    function($rootScope, $resource, NotifyService){

      var VipInfo = $resource("/qr_code/:action",{},{
        verify: { method: "get", params: { action: "verify_vip_info"}},
        reload: { method: "get", params: { action: "reload_verify_qrcode"}}
      })

      function verify(qrcode_success, success, scan_success, vip_only){
        NotifyService.set_message_handler("VERIFY_VIPINFO", function(msg){
          if($rootScope.is_self_message(msg) && success){
            success(msg.vip_info)
            NotifyService.remove_message_handler("VERIFY_VIPINFO")
          }
        })
        NotifyService.set_message_handler("VERIFY_VIPINFO_SCAN_SUCCESS", function(msg){
          if($rootScope.is_self_message(msg) && scan_success){
            scan_success();
            NotifyService.remove_message_handler("VERIFY_VIPINFO_SCAN_SUCCESS")
          }
        })
        VipInfo.verify({vip_only: vip_only},function(qrcode){
          if(qrcode_success){ qrcode_success(qrcode.url)}
        })
      }

      function reload_qrcode(success, vip_only){
        VipInfo.reload({vip_only: vip_only}, success)
      }

      return{
        verify: verify,
        reload_qrcode: reload_qrcode
      }
    }]);
