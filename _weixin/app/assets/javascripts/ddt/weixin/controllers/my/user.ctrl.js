"use strict"

Ddt.controller('userController', [
  '$rootScope', '$scope', '$location','UserService', 'ShopService',
  function($rootScope, $scope, $location, UserService, ShopService){

}]).controller('userScanCodeController', [
  '$rootScope', '$scope', 'UserService', '$interval',
  function($rootScope, $scope, UserService, $interval){
    $rootScope.title = '会员付款码';

    function get_scan_code(){
      UserService.scan_code(function(code){
        $scope.code = code
      })
    }

    UserService.get(function(user){
      $scope.user = user;
    });

    var refresh_interval = undefined;
    if($scope.user.is_vip){
      get_scan_code()
      var refresh_interval = $interval(get_scan_code, 100000)
    }

    $scope.$on("$destroy", function(){
      if (angular.isDefined(refresh_interval)) {
        $interval.cancel(refresh_interval);
        refresh_interval = undefined;
      }
    })

}]).controller('userUpdatePayPasswordController', [
  '$rootScope', '$scope', 'UserService',
  function($rootScope, $scope, UserService){
    $rootScope.title = '更改支付密码';
    UserService.get(function(user){
      $scope.user = user;
    });

    $scope.can_submit = function(){
      return $scope.user.new_pay_password
    }

    $scope.submit = function(){
      if($scope.can_submit()){
        UserService.update_pay_password($scope.user.current_pay_password, $scope.user.new_pay_password, function(user){
          $scope.user = user;
          $rootScope.$broadcast("events:success_info", "支付密码修改成功")
          $rootScope.go('/user/profile')
        })
      }
    }

}]).controller('userBindVipController', [
  '$rootScope', '$scope', '$interval', 'UserService',
  function($rootScope, $scope, $interval, UserService){
    $rootScope.title = '绑定会员';

    $scope.validation_time = undefined
    $scope.validation_time_interval = undefined
    $scope.sms_captcha_id = undefined;
    $scope.vip_info = {};

    UserService.get(function(user){
      $scope.user = user;
      $scope.vip_info = $scope.user.vip_info;
    });

    $scope.can_submit = function(){
      if($rootScope.current_shop.user_sms && $rootScope.current_shop.enable_vip_info_phone_validation){
        return $scope.vip_info.phone && $scope.vip_info.password && $scope.vip_info.sms_captcha_code && $scope.sms_captcha_id
      }else{
        return $scope.vip_info.phone && $scope.vip_info.password
      }
    }

    $scope.submit = function(){
      if($scope.can_submit()){
        UserService.bind_vip({
          phone: $scope.vip_info.phone,
          password: $scope.vip_info.password,
          sms_captcha_code: $scope.vip_info.sms_captcha_code,
          sms_captcha_id: $scope.sms_captcha_id
        }, function(user){
          UserService.set(user);
          $rootScope.$broadcast("events:success_info", "绑定会员成功")
          $rootScope.go('/user/profile')
        })
      }
    }

    $scope.send_validation_code = function(){
      if($scope.validation_time) return;
      var phone = $scope.vip_info.phone + '';
      if (phone && phone.match(/^\d{11}$/)) {
        UserService.send_vip_info_phone_validation_code(phone, function(resp) {
          $scope.$emit("events:success_info", "验证码已经发送，请查看短信并将收到的验证码正确填写。")
          $scope.validation_time = 60;
          $scope.sms_captcha_id = resp.id;
          $scope.validation_time_interval = $interval(function(){
            if($scope.validation_time <= 0 ){
              $scope.validation_time = undefined
              $interval.cancel($scope.validation_time_interval);
            }else{
              $scope.validation_time --;
            }
          }, 1000);
        });
      } else {
        $rootScope.$emit("events:receive_errors", '请填写正确的手机号码');
      }
    }

    $scope.$on('$destroy', function(){
      if (angular.isDefined($scope.validation_time_interval)) {
        $interval.cancel($scope.validation_time_interval);
        $scope.validation_time_interval = undefined;
      }
    })

}]).controller('userVipInfoDetailController', [
 '$rootScope', '$scope', 'UserService',
 function($rootScope, $scope, UserService){
  $rootScope.title = "会员基本信息"
   UserService.get(function(user){
        $scope.user = user;
    })

}]).controller('userCardWalletLogController', [
  '$rootScope', '$scope', 'UserService',
  function($rootScope, $scope, UserService){
    $rootScope.title = '余额流水'
    UserService.get(function(user){
      $scope.user = user;
    })

    $scope.refresh = function(){
      UserService.get_card_wallet_logs(function(wallet_logs){
        $scope.wallet_logs = wallet_logs;
      });
    }

    $scope.refresh();
}]).controller('updateVipInfoController', [
  '$rootScope', '$scope', '$interval','UserService', 'VipInfoSettingService',
  function($rootScope, $scope, $interval, UserService, VipInfoSettingService){

    console.log($rootScope.current_shop)
    VipInfoSettingService.get({}).$promise.then(function(setting){
      $scope.setting = setting
    })

    $rootScope.title = ""
    $scope.vip_info = {
      name: '',
      phone: '',
      sex: '',
      birthday: '',
      address: '',
      email: ''
    }
    $scope.validation_time = undefined
    $scope.validation_time_interval = undefined

    $scope.sex_collection = [{value: 'male', name: '男'},{value: 'female', name: '女'}]

    UserService.get(function(user){
      $scope.user = user;
      $scope.vip_info.name      = user.vip_info.name
      $scope.vip_info.phone     = user.vip_info.phone
      $scope.vip_info.sex       = user.vip_info.sex
      // $scope.vip_info.birthday  = new Date(user.vip_info.birthday)
      $scope.vip_info.address   = user.vip_info.address
      $scope.vip_info.email     = user.vip_info.email
      $scope.vip_info.source_user_id = UrlParser.query_parameter('_share_user_id')
      $scope.is_vip = user.is_vip

      $rootScope.title = $scope.user.is_vip ? "修改会员信息" : "申请会员"
    });

    $scope.can_submit = function(){
      if($scope.user.is_vip){
        return true
      }else if($rootScope.current_shop.user_sms && $rootScope.current_shop.enable_vip_info_phone_validation){
        return $scope.vip_info.phone && $scope.vip_info.name && $scope.vip_info.validation_code
      }else{
        return $scope.setting &&
              (!$scope.setting.name_required || $scope.vip_info.name) &&
              (!$scope.setting.phone_required || $scope.vip_info.phone) &&
              (!$scope.setting.sex_required || $scope.vip_info.sex) &&
              (!$scope.setting.birthday_required || $scope.vip_info.birthday) &&
              (!$scope.setting.address_required || $scope.vip_info.address) &&
              (!$scope.setting.email_required || $scope.vip_info.email)
      }
    }

    $scope.submit = function(){
      if($scope.can_submit()){
        var from_branch_id = UrlParser.query_parameter('from_branch_id')
        if(from_branch_id){
          $scope.vip_info.from_branch_id = from_branch_id
        }
        $scope.vip_info.birthday = $scope.vip_info.birthday.toDateString()
        UserService.update_vip_info($scope.vip_info, $scope.sms_captcha_id, $scope.vip_info.sms_captcha_code, function(user){
          if(!$scope.user.is_vip){
            $rootScope.$broadcast("events:success_info", "申请成功，等待审核")
          }
          $rootScope.go('/user/profile')
        })
      }
    }

    $scope.send_validation_code = function(){
      if($scope.validation_time) return;
      var phone = $scope.vip_info.phone + '';
      if (phone && phone.match(/^\d{11}$/)) {
        UserService.send_vip_info_phone_validation_code(phone, function(resp) {
          $scope.sms_captcha_id = resp.id;
          $scope.$emit("events:success_info", "验证码已经发送，请查看短信并将收到的验证码正确填写。")
          $scope.validation_time = 60;
          $scope.validation_time_interval = $interval(function(){
            if($scope.validation_time <= 0 ){
              $scope.validation_time = undefined
              $interval.cancel($scope.validation_time_interval);
            }else{
              $scope.validation_time --;
            }
          }, 1000);
        });
      } else {
        $rootScope.$emit("events:receive_errors", '请填写正确的手机号码');
      }
    }

    $scope.$on("$destroy", function(){
      if (angular.isDefined($scope.validation_time_interval)) {
        $interval.cancel($scope.validation_time_interval);
        $scope.validation_time_interval = undefined;
      }
    })
}])

