Ddt.module("ddt_app.controllers.cart.address", [])
  .controller('addressesController', [
  '$rootScope', '$scope', '$compile', '$location', 'AddressService','UserService',
  function($rootScope, $scope, $compile, $location, AddressService, UserService){
    $rootScope.title = '收货地址管理';
    $scope.is_editing = false;

    UserService.get(function(user){
      $scope.user = user;
    });

    AddressService.query(function(addresses){
      $scope.addresses = addresses;
      angular.forEach(addresses, function(address){
        if(address.is_default){
          $scope.user.default_address_id = address.id
        }
      })
      if(!$scope.user.default_address_id && addresses.length > 0){
        $scope.set_default(addresses[0]);
        $scope.user.default_address_id = addresses[0].id;
      }
      console.log(addresses)
    });

    $scope.set_default = function(address){
      var update_user_and_jump_back = function(){
        UserService.update_default_address(address)
        var url = AddressService.restore_url();
        if(url){
          $location.path(url);
        }
      }
      if(address.id == $scope.user.default_address_id){
        update_user_and_jump_back();
        return;
      }
      AddressService.set_default(address.id, function(addresses){
        $scope.addresses = addresses;
        $scope.user.default_address_id = address.id
        update_user_and_jump_back();
      })
    }

    $scope.new_address = function(){
      $rootScope.go("/addresses/new", false);
    }

    $scope.editAddress = function(address){
      $rootScope.go("/addresses/"+ address.id+"/edit")
    }

    
    $scope.toggle_edit_state = function(){
      $scope.is_editing = !$scope.is_editing;
    }
}]).factory('ValidationCodeHelper', ['ShopService', 'UserService', function(ShopService, UserService) {

  var commonAction = function($rootScope, $scope) {
    $scope.is_code_sent = false;

    ShopService.get(function(shop) {
      $scope.is_use_validation_sms = shop.use_validation_sms;
    });

    $scope.is_phone_changed = function() {
      var result = $scope.address && ($scope.address.phone != $scope.original_phone);
      return result;
    }

    $scope.is_need_validation = function() {
      return $scope.is_use_validation_sms && $scope.is_phone_changed();
    };

    $scope.send_code = function() {
      if (!$scope.is_code_sent) {
        var phone = $scope.address.phone;
        if (phone.match(/^\d{11}$/)) {
          UserService.send_validation_code(phone, function(resp) {
            $scope.sms_captcha_id = resp.id;
            $scope.is_code_sent = true;
            $scope.$emit("events:success_info", "验证码已经发送，请查看短信并将收到的验证码正确填写。")
            var left_time = 60;
            var timer = setInterval(function(){
              $scope.$apply(function(){
                if(left_time <= 0 ){
                  $scope.button_value = "重新发送验证码";
                  $scope.is_code_sent = false;
                  clearInterval(timer);
                }else{
                  $scope.button_value = left_time+"秒后可重新发送";
                  left_time --;
                }
              });
            }, 1000);
          });
        } else {
          $rootScope.$emit("events:receive_errors", '请填写正确的手机号码');
        }
      }
    };

    $scope.is_correct_code = UserService.is_correct_code;


  };

  return {commonAction: commonAction};

}]).controller('newAddressController', [
  '$rootScope', '$scope', '$location', 'baseAddressController', 'UserService', 'AddressService', 'ValidationCodeHelper','GeolocationService',
  function ($rootScope, $scope, $location, baseAddressController, UserService, AddressService, ValidationCodeHelper, GeolocationService) {
    $scope.self = $scope;

    baseAddressController.action($scope, function () {})


    $scope.address = AddressService.restore_address();

    // if(!$scope.enable_foreign && !($scope.address.latitude && $scope.address.longitude) ){
    //   $scope.chose_location($scope.address);
    // }

    $rootScope.title = '新建地址'
    $scope.original_phone = null;
    ValidationCodeHelper.commonAction($rootScope, $scope);

    GeolocationService.get_current_position(function(position) {
      if (position.address){
        // $scope.address.content = position.address.formatted_address;
        $scope.address.city_name = position.address.city;
      }
    })

    function submit_address(){
      if($scope.lack_latlng()){
        $rootScope.$emit("events:receive_errors", "请点击选择小区地址");
      }else if(!$scope.address.room_no){
        $rootScope.$emit("events:receive_errors", "请输入门牌号");
      }else{
        create_address($scope.address);
      }
    }

    $scope.submit =  function(){
      if($scope.can_submit()){
        if($scope.is_need_validation()){
          $scope.is_correct_code($scope.sms_captcha_id, $scope.address.sms_captcha_code, $scope.address.phone, function() {
            submit_address();
          })
        }else{
          submit_address();
        }
      }
    }

    var create_address = function(address){
      AddressService.create(address, function(address){
        AddressService.delete_store_address();
        var url = AddressService.restore_url();
        if(url){
          AddressService.set_default(address.id, function(addresses){
            UserService.update_default_address(address);
            $location.path(url);
          })
        }else{
          if(address.is_default){
            UserService.update_default_address(address);
          }
        }
        $rootScope.go('/addresses')
      });
    }

}]).controller('editAddressController', ['$rootScope', '$scope', '$routeParams', '$location', 'baseAddressController', 'AddressService', 'ValidationCodeHelper',
  function ($rootScope, $scope, $routeParams, $location, baseAddressController, AddressService, ValidationCodeHelper) {

    baseAddressController.action($scope, function () {})

    $rootScope.title = '修改地址'
    AddressService.get($routeParams.address_id, function(address){
      $scope.address = address;
      $scope.original_phone = address.phone;
      if($scope.enable_foreign){
        if($scope.address.latitude==null || $scope.address.longitude==null){
          AddressService.store_url($location.path());
          $rootScope.go("/addresses/" + address.id + "/chose_location", false);
        }
      }
    });

    ValidationCodeHelper.commonAction($rootScope, $scope);

    function submitHandler(){
      if($scope.lack_latlng()){
        $rootScope.$emit("events:receive_errors", "请点击选择小区地址");
      }else if(!$scope.address.room_no){
        $rootScope.$emit("events:receive_errors", "请输入门牌号");
      }
      AddressService.update($scope.address.id, $scope.address, function(){
        $rootScope.go('/addresses')
      })
    }

    $scope.submit =  function(){
      if($scope.can_submit()){
        if($scope.is_need_validation()){
          $scope.is_correct_code($scope.sms_captcha_id, $scope.address.sms_captcha_code, $scope.address.phone, function(resp) {
            submitHandler();
          });
        } else {
          submitHandler();
        }
      }
    }
}]).factory('baseAddressController',[
  '$rootScope', '$timeout','AddressService', 'UserService', 'ShopService', 'GeolocationService',
  function($rootScope, $timeout, AddressService, UserService, ShopService, GeolocationService){
    function action(scope, callback){
      scope.enable_foreign = false;

      ShopService.get(function(shop){
        scope.enable_foreign = shop.enable_foreign
      })

      scope.can_submit = function(){
        var errors = []
        if(!scope.address.name){ errors.push("请填写姓名") }
        if(!scope.address.phone){ errors.push("请填写电话") }
        if(!scope.address.building){ errors.push("请填写小区")}
        if(!scope.address.room_no){ errors.push("请填写门牌号")}
        if(errors.length>0){
          $rootScope.$emit("events:receive_errors", errors);
          return false;
        }
        return true;
      }


    scope.back_to_edit = function(){
      scope.building = '';
      scope.input_address = false;
    }

    scope.show_input_address_modal = function(){
      scope.input_address = true;
    }

    scope.open_location = function(address){
      if(address&& address.latitude && address.longitude){
        wx.openLocation({
          latitude: address.latitude,
          longitude: address.longitude,
          name: '我的位置',
          address: address.content,
          scale: 16
        });
      }else{
        wx.getLocation({
          type: 'wgs84', // 默认为wgs84的gps坐标，如果要返回直接给openLocation用的火星坐标，可传入'gcj02'
          success: function (res) {
            wx.openLocation({
              latitude: res.latitude,
              longitude: res.longitude,
              name: '我的位置',
              address: '',
              scale: 16
            });
          }
        });
      }
    }

      scope.lack_latlng = function(){
        if(scope.enable_foreign){
          return !scope.address.latitude || !scope.address.longitude
        }else{
          return false;
        }
      }

      scope.addresses = [];
      var timer = undefined;

      function cancel_query_timer(){
        if(timer){
          $timeout.cancel( timer );
        }
      }

      scope.loading_addresses = function(input){
        if(!scope.enable_foreign){
          if(input && scope.address.city_name){
            cancel_query_timer();
            timer = $timeout(function(){
              GeolocationService.search_address(input, scope.address.city_name, function(addresses){
                scope.addresses = addresses
                scope.$apply(function(){})
              })
            }, 300);
          }
        } else {
          if (input){
            cancel_query_timer();
            timer = $timeout(function(){
              GeolocationService.search_address_by_google(input, function(addresses){
                scope.addresses = addresses
                scope.$apply(function(){})
              })
            }, 300);
          }
        }
      }

      scope.destroy = function(address){
        AddressService.destroy(address.id, function(result){
          UserService.update_default_address(null);
          $rootScope.go('/addresses');

        });
      }

      scope.select_address = function(address){
        scope.address.building = address.name;
        scope.address.latitude  = address.latLng.lat;
        scope.address.longitude = address.latLng.lng;
        scope.addresses = [];
        cancel_query_timer();
        scope.input_address = false;
      }

    }
    return { action: action}
  }
  ])
