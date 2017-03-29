(function($){

  //config信息,如果过期，须重新通过ajax获取
  var wxConfigAppId = $('meta[name="wxConfigAppId"]').attr('content');
  var wxConfigTimestamp = $('meta[name="wxConfigTimestamp"]').attr('content');
  var wxConfigNonceStr = $('meta[name="wxConfigNonceStr"]').attr('content');
  var wxConfigSignature = $('meta[name="wxConfigSignature"]').attr('content');

  function htmlToText(html){
     var tmp = document.createElement("DIV");
     tmp.innerHTML = html;
     return tmp.textContent || tmp.innerText || "";
  };

  function authenticateApp(){
    //即微信文档的步骤二：通过config接口注入权限验证配置
    wx.config({
      debug: false, // 开启调试模式,调用的所有api的返回值会在客户端alert出来，若要查看传入的参数，可以在pc端打开，参数信息会通过log打出，仅在pc端时才会打印。
      appId: wxConfigAppId, // 必填，公众号的唯一标识
      timestamp: parseInt(wxConfigTimestamp), // 必填，生成签名的时间戳
      nonceStr: wxConfigNonceStr, // 必填，生成签名的随机串
      signature: wxConfigSignature,// 必填，签名，见附录1
      jsApiList: [ 'checkJsApi',
        'onMenuShareTimeline',
        'onMenuShareAppMessage',
        'onMenuShareQQ',
        'onMenuShareWeibo',
        'hideMenuItems',
        'showMenuItems',
        'hideAllNonBaseMenuItem',
        'showAllNonBaseMenuItem',
        'translateVoice',
        'startRecord',
        'stopRecord',
        'onRecordEnd',
        'playVoice',
        'pauseVoice',
        'stopVoice',
        'uploadVoice',
        'downloadVoice',
        'chooseImage',
        'previewImage',
        'uploadImage',
        'downloadImage',
        'getNetworkType',
        'openLocation',
        'getLocation',
        'hideOptionMenu',
        'showOptionMenu',
        'closeWindow',
        'scanQRCode',
        'chooseWXPay',
        'openProductSpecificView',
        'addCard',
        'chooseCard',
        'openCard'
      ] // 必填，需要使用的JS接口列表，所有JS接口列表见附录2
    });
  };

  function reloadWxConfig(){
    //通过Ajax重载config信息
    //TODO: 未完成
    //window.location.reload();
  };

  var shareCallback = {};

  //利用js语言的对象引用特征，我们可以实现异步设置分享信息
  var wxShareConfig = {
    title: '', // 分享标题
    desc: '',
    link: '', // 分享链接
    imgUrl: '', // 分享图标
    success: function (resp) {
        // 用户确认分享后执行的回调函数
        if(shareCallback.shareSuccess){
          shareCallback.shareSuccess(resp, this);
        }
    },
    cancel: function (resp) {
        // 用户取消分享后执行的回调函数
        if(shareCallback.shareCancel){
          shareCallback.shareCancel(resp, this);
        }
    },
    complete: function(resp){
      //接口调用完成时执行的回调函数，无论成功或失败都会执行。
      if(shareCallback.shareComplete){
          shareCallback.shareComplete(resp, this);
        }
    },
    fail: function(resp){
      //接口调用失败时执行的回调函数。
      if(shareCallback.shareFail){
          shareCallback.shareFail(resp, this);
        }
    },
    trigger: function(resp){
      //用户点击分享时触发的异步事件
      if(shareCallback.shareTrigger){
        shareCallback.shareTrigger(resp, this);
      }
      this.desc = htmlToText(this.desc);
    }
  };

  var WeixinApiService = {};

  WeixinApiService.isWeixinConfigOK = false;  //微信js开放接口授权是否通过

  WeixinApiService.init = function(){
    var This = this;
    if(typeof wx != 'undefined'){
      authenticateApp();
      wx.ready(function(){
          This.isWeixinConfigOK = true; //注入权限验证成功
          // config信息验证后会执行ready方法，所有接口调用都必须在config接口获得结果之后，config是一个客户端的异步操作，所以如果需要在页面加载时就调用相关接口，则须把相关接口放在ready函数中调用来确保正确执行。对于用户触发时才调用的接口，则可以直接调用，不需要放在ready函数中。
          // 必须是认证账号才能定制分享
          wx.onMenuShareTimeline(wxShareConfig);
          wx.onMenuShareAppMessage(wxShareConfig);
          wx.onMenuShareQQ(wxShareConfig);
          wx.onMenuShareWeibo(wxShareConfig);
      });

      wx.error(function(res){
        This.isWeixinConfigOK = false;
        // config信息验证失败会执行error函数，如签名过期导致验证失败，具体错误信息可以打开config的debug模式查看，也可以在返回的res参数中查看，对于SPA可以在这里更新签名。

        alert('加载微信jssdk失败，请管理员检查如下信息：公众号平台的JS接口安全域名须设置为diandantong.com，第三方平台的主公众账号AppId和AppSecret是否设置正确。' + JSON.stringify(res));
        reloadWxConfig();
      });
    }
  };

  //
  // 本方法有两种参数形式
  // 1. 使用方法签名所示，传入分享回调函数。
  // 2. 传入一个对象，对象属性是对应回调函数。
  //
  // 所有callback均采取function(resp, wxShareConfig)，其中resp表示分享成功后的回调结果, wxShareConfig为分享的配置信息
  // 注: 在 controller 里实际使用 ddt.js 里封装的 shareRecordTrigger
  //
  WeixinApiService.bindShareCallback = function(shareTrigger, shareSuccess, shareFail, shareCancel, shareComplete){
    if (typeof shareTrigger == 'function'){
      shareCallback.shareTrigger = shareTrigger;
      shareCallback.shareSuccess = shareSuccess;
      shareCallback.shareFail = shareFail;
      shareCallback.shareCancel = shareCancel;
      shareCallback.shareComplete = shareComplete;
    }else{
      var opts = shareTrigger;
      $.each('shareTrigger shareSuccess shareFail shareCancel shareComplete'.split(/\s+/), function(i, name){
        shareCallback[name] = opts[name];
      });
    }
  };

  WeixinApiService.openInWeixin = function(){
    return /MicroMessenger/i.test(navigator.userAgent);
  }

  WeixinApiService.init();

  window.WeixinApi = WeixinApiService;
})(window.jQuery||window.Zepto);
