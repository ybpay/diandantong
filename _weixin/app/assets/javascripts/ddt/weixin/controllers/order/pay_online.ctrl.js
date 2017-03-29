Ddt.module('ddt.controllers.pay_online', ['ipCookie'])
.controller('payOnlineController',
  ['$rootScope', '$scope', '$routeParams', '$location', 'BaseOrderService', 'ipCookie', 'DdtConst',
  function($rootScope, $scope, $routeParams, $location, BaseOrderService, ipCookie, DdtConst){

    showLoadingMask();
    $scope.$on('$destroy', function(){
      hideLoadingMask();
    })

    $scope.branch_id = $routeParams.branch_id;
    $scope.order_type = $routeParams.order_type;
    $scope.order_id = $routeParams.order_id;

    var invoke_wechat_pay_legacy = function (data) {
      wx.chooseWXPay({
        timestamp: data.timeStamp, // 支付签名时间戳
        nonceStr: data.nonceStr, // 支付签名随机串
        package: data.package, // 订单详情扩展字符串，详见附录5
        paySign: data.paySign, // 支付签名，详见附录5
        success: function () {
          $scope.$emit("events:success_info", '支付成功，等待3秒后返回... ...');
        },
        fail: function() {
          alert("支付失败，请检查错误或者重新尝试！");
        },
        cancel: function() {
          alert("支付取消！");
        }
      });
    };

    var invoke_wechat_pay_v336 = function(data){
      window.location.href = DdtConst.baseUrl + '?act=invoke_wechatpay_v3&order_id=' + $scope.order_id;

      //var action_url = DdtConst.baseUrl;
      //var params = {
      //  invoke_wechatpay_v3: true,    // 跳转支付识别参数
      //  'data[callback_url]': DdtConst.baseUrl + '?_ng_path=/branches/' + $scope.branch_id + '/orders/' + $scope.order_type + '/' + $scope.order_id  // 回调参数
      //}
      //params[$('meta[name="csrf-param"]').attr('content')] = $('meta[name="csrf-token"]').attr('content');  // CSRF 参数
      //angular.forEach(['appId', 'timeStamp', 'nonceStr', 'package', 'signType', 'paySign'], function(it){
      //  params['name', 'data[' + it + ']'] = data[it];  // 支付参数
      //});
      //window.location.href = action_url + "?" + $.map(params, function(value, key){
      //  return encodeURIComponent(key) + '=' + encodeURIComponent(value);
      //}).join('&');

      //WeixinJSBridge.invoke('getBrandWCPayRequest',
      //  {
      //    "appId": data.appId,
      //    "timeStamp": data.timeStamp,
      //    "nonceStr": data.nonceStr,
      //    "package": data.package,
      //    "signType": data.signType,
      //    "paySign": data.paySign
      //  }
      //  ,
      //  function(res){
      //    if(res.err_msg == "get_brand_wcpay_request:ok" ) {
      //      $scope.$emit("events:success_info", '支付成功，等待3秒后返回... ...');
      //    } else if(res.err_msg == "get_brand_wcpay_request:cancel") {
      //      alert("支付取消！");
      //    } else if(res.err_msg == "get_brand_wcpay_request:fail") {
      //      alert("支付失败，请检查错误或者重新尝试！");
      //    } else if(res.err_msg == "system:access_denied" || res.err_msg == "access_control:not_allow" || res.err_msg == 'getBrandWCPayRequest:fail_invalid appid'){
      //      alert('请关注我们的公众帐号，进行微信支付');
      //    } else {
      //      alert(res.err_msg);
      //    }
      //  }
      //);
    };

    var pay_online = function(){
      BaseOrderService.get_pay_online($scope.order_type, $scope.branch_id, $scope.order_id, function (result) {
        switch (result.method) {
          case 'alipay':
            switch(result.data_type){
              case 'url':
                var query = {
                  shop_id: $rootScope.shop.id,
                  branch_id: $scope.branch_id,
                  order_type: $scope.order_type,
                  order_id: $scope.order_id,
                  wap_url: result.data
                }
                window.location.href = '/weixin/invoke_alipay.html?' + $.param(query)
                // if ($rootScope.is_in_weixin){
                //   window.location.href = '/weixin/invoke_alipay.html?redirect=' + encodeURIComponent(result.data)
                // } else {
                //   window.location.href = result.data
                // }
                break;
              case 'html':
                document.write(result.data)
                break;
            }
            break;
          case 'baidupay':
            window.location.href = result.data;
            break;
          case 'wechatpay':
            switch (result.data_type) {
              case 'NATIVE':
                alert('events:receive_errors', '不应该使用 NATIVE 方式的微信支付');
                break;
              case 'JSAPI':
                if (result.version == 'legacy') {
                  invoke_wechat_pay_legacy(result.data);
                } else {
                  invoke_wechat_pay_v336(result.data);
                }
                break;
              case 'oauth2_url':
                // 需要获取 open_id
                ipCookie('validate_wechatpay_user_info', true, {expires: 30, expirationUnit: 'seconds'})
                var url = UrlParser.change_parameter(window.location, '_ng_path', $location.path());
                url = UrlParser.change_parameter(url, 'invoke_pay_online', $scope.order_id);
                window.location.href = url
            }
            break;
          case 'exception':
            alert("在线支付出错了！请检查后台支付参数设置是否正确.\n" + JSON.stringify(result.data));
            break;
        }
      });
    }

    pay_online();


  }])
