WebposModules.add_service('tts')
angular.module('webpos.services.tts', []).
  factory('TtsService', ['$timeout', '$rootScope', 'FlashPlayerService','TtsLocalService',
    function($timeout, $rootScope, FlashPlayerService,TtsLocalService){
    var appid = "55a65409";
    var secret_key = "694996ccbe3c3d0e";
    var caches = {}
    var session = new IFlyTtsSession({
      'url' : 'http://webapi.openspeech.cn/',
      'interval' : '30000',
      'disconnect_hint' : 'disconnect',
      'sub' : 'tts'
    });
    var current_url = null;
    var loading = false;
    var audio = null;
    // 声音
    var vcn = 'xiaoyan';
    var vcns = [
      { value: 'xiaoyan'   , name: '普通话' }, //会吞掉最后一个字音
      // { value: 'xiaoyu'    , name: '青年男声, 普通话' },
      // { value: 'Catherine' , name: '英文女声' },
      // { value: 'henry'     , name: '英文男声' },
      // { value: 'vixy'      , name: '普通话' },
      { value: 'vixm'      , name: '粤语' },
      { value: 'vixl'      , name: '台湾普通话' },
      { value: 'vixr'      , name: '四川话' },
      { value: 'vixyun'    , name: '东北话' },
    ]
    // 语速
    var spd = 6; // 0-10 0最慢 10最快
    // 音量
    var vol = 10; // 0-10 0没声 10最响

    function get_vcns(){ return vcns;}
    function get_vcn(){ return vcn; }
    function get_spd(){ return spd; }
    function get_vol(){ return vol; }
    function set_vcn(new_vcn){ vcn = new_vcn; caches={}; }
    function set_spd(new_spd){ spd = new_spd; caches={}; }
    function set_vol(new_vol){ vol = new_vol; caches={}; }

    function play(text, count){
      if($rootScope.branch && $rootScope.branch.enable_tts_local && TtsLocalService.has_object()){
        TtsLocalService.play(text, spd * 10, vol * 10).catch(function(ret){
          if (ret != 0){
            $rootScope.alert("语音合成错误, 错误代码" + ret)
          }
        })
        return
      }
      text = text+"。";
      if(caches[text]){
        play_url(caches[text], count)
      }else{
        if(!loading){
          var timestamp = new Date().getTime();//当前时间戳，例new Date().toLocaleTimeString()
          var expires = 60000;                            //签名失效时间，单位:ms，例60000
          var signature = faultylabs.MD5(appid + '&' + timestamp + '&' + expires + '&' + secret_key);

          var params = {
            "params" : "aue = speex-wb;7, ent = intp65, spd="+spd+", vol="+vol+", tte = utf8, caller.appid=" + appid + ",timestamp=" + timestamp + ",expires=" + expires + ", vcn=" + vcn,
            "signature" : signature,
            "gat": "mp3"
          };
          loading = true
          session.start(params, text, function (err, obj){
            if(err) {
              alert("语音合成发生错误，错误代码 ：" + err);
            } else {
              current_url = "http://webapi.openspeech.cn/" + obj.audio_url;
            }
          }, function(message){
            if(message === 'onEnd' && current_url){
              caches[text] = current_url
              $timeout(function(){
                play_url(current_url, count)
                current_url = null
                loading = false
              }, 100)
            }
          });
        }
      }
    }

    function play_url(url, count){
      if(typeof count === undefined){ count = 1; }
      if($rootScope.is_cef){
        FlashPlayerService.play(url, count)
      }else{
        if(audio != null){
          audio.pause();
        }
        audio = new Audio();
        audio.src = url
        audio.addEventListener('ended', function(){
          if(--count){
            audio.currentTime = 0;
            audio.play();
          }else{
            audio.pause();
          }
        });
        audio.play();
      }
    }

    return {
      get_vcns: get_vcns,
      get_vcn: get_vcn,
      get_spd: get_spd,
      get_vol: get_vol,
      set_vcn: set_vcn,
      set_spd: set_spd,
      set_vol: set_vol,
      play: play,
    }
  }])
