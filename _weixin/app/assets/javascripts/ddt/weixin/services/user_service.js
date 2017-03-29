Ddt.factory('UserService', ['$http', '$rootScope' , '$resource', 'DdtConst',
      function ($http, $rootScope, $resource, DdtConst) {

      var user = JSON.parse($('meta[name="user_json"]').attr("content"));
      var User = $resource(DdtConst.baseUrl + '/user/:action', { format: 'json'},{
        show: {method: 'get'},
        scan_code: {method: 'get', params: { action: 'scan_code'}},
        update_vip_info: { method: 'post', params: { action: 'update_vip_info'}},
        apply_vip: { method: 'post', params: { action: 'apply_vip'}},
        update_pay_password: { method: 'post', params: { action: 'update_pay_password'}},
        send_vip_info_phone_validation_code: { method: 'post', params: { action: 'send_vip_info_phone_validation_code'}},
        send_validation_code: { method: 'post', params: { action: 'send_validation_code'}},
        is_correct_code: { method: 'get', params: { action: 'is_correct_code'}},
        authenticate_password: { method: 'post', params: { action: 'authenticate_password'}},
        bind_vip: { method: 'post', params: { action: 'bind_vip'}},
        card_wallet_logs: { method: 'get', params: {action: 'card_wallet_logs'}, isArray: true},
        credits_wallet_logs: {method: 'get', params: {action: 'credits_wallet_logs'}, isArray: true}
      })
      function get(success){
        success(user);
      }

      function scan_code(success){
        User.scan_code(function(code){
          if(success){success(code)}
        })
      }

      function set(new_user){
        user = new_user
      }

      function update_default_address(address){
        user.default_address = address;
      }

      function refresh(success){
        User.show(function(user){
          set(user);
          if(success){
            success(user);
          }
        })
      }

      function update_vip_info(vip_info, sms_captcha_id, sms_captcha_code, success){
        User.update_vip_info({}, {
          vip_info: vip_info,
          sms_captcha_id: sms_captcha_id,
          sms_captcha_code: sms_captcha_code
        }, function(user){
          set(user)
          if(success){success(user)}
        })
      }

      function apply_vip(success){
        User.apply_vip({}, {}, function(){
          user.vip_info.is_apply_vip = true
          success();
        })
      }

      function update_pay_password(current_pay_password, new_pay_password, success){
        User.update_pay_password({}, {
          current_pay_password: current_pay_password,
          new_pay_password: new_pay_password
        }, function(user){
          set(user);
          if(success){success(user)}
        })
      }

      function send_validation_code(to, success) {
        User.send_validation_code({to: to}, {}, success);
      }

      function send_vip_info_phone_validation_code(phone, success) {
        User.send_vip_info_phone_validation_code({to: phone}, {}, success);
      }

      function is_correct_code(sms_captcha_id, sms_captcha_code, phone, success) {
        User.is_correct_code({
          phone: phone,
          sms_captcha_id: sms_captcha_id, 
          sms_captcha_code: sms_captcha_code
        }, {}, success);
      }

      function authenticate_password(password, success){
        User.authenticate_password({}, {password: password}, success)
      }

      function bind_vip(bind_vip_info, success){
        User.bind_vip({}, { 
          phone: bind_vip_info.phone, 
          password: bind_vip_info.password, 
          sms_captcha_id: bind_vip_info.sms_captcha_id, 
          sms_captcha_code: bind_vip_info.sms_captcha_code
        }, success)
      }

      function get_card_wallet_logs(success){
        User.card_wallet_logs({}, success);
      }

      function get_credits_wallet_logs(params, success){
        User.credits_wallet_logs(params, success);
      }

      return {
        get:get,
        scan_code:scan_code,
        set:set,
        update_default_address: update_default_address,
        refresh: refresh,
        update_vip_info: update_vip_info,
        apply_vip: apply_vip,
        update_pay_password: update_pay_password,
        send_vip_info_phone_validation_code: send_vip_info_phone_validation_code,
        send_validation_code: send_validation_code,
        is_correct_code: is_correct_code,
        authenticate_password: authenticate_password,
        bind_vip: bind_vip,
        get_card_wallet_logs: get_card_wallet_logs,
        get_credits_wallet_logs: get_credits_wallet_logs
      }
    }]);
