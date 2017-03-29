var version_timestamp = "?v" + ('development' != WebposConst.env ? "201609270952" : Date.parse(new Date()));
var ls_version = '201609270952'
var WebposModules = (function(){
  var services = []
  var controllers = []
  var directives = []
  var actions = []
  var cells = []
  var modules = []

  function add(module){ modules.push(module)}
  function add_service(service){ services.push(service)}
  function add_controller(controller){ controllers.push(controller) }
  function add_directive(directive){ directives.push(directive) }
  function add_action(action){ actions.push(action) }
  function add_cell(cell){ cells.push(cell) }

  function get(others){
    var all = []
    services.forEach(function(service){ all.push("webpos.services." + service) })
    controllers.forEach(function(controller){ all.push("webpos.controllers." + controller) })
    directives.forEach(function(directive){ all.push("webpos.directives." + directive) })
    actions.forEach(function(action){ all.push("webpos.actions." + action) })
    cells.forEach(function(cell){ all.push("webpos.cells." + cell) })
    modules.forEach(function(module){ all.push("webpos." + module) })
    return all.concat(others)
  }

  return {
    add_service: add_service,
    add_controller: add_controller,
    add_directive: add_directive,
    add_action: add_action,
    add_cell: add_cell,
    add: add,
    get: get
  }
})();

function touchScroll(selector){
    var scrollStartPos = 0;
    $(selector).on('touchstart', function(event) {
        scrollStartPos = this.scrollTop + event.originalEvent.touches[0].pageY;
    });
    $(selector).on('touchmove', function(event) {
        this.scrollTop = scrollStartPos - event.originalEvent.touches[0].pageY;
    });
}



//==========================================================================================
// 添加 String 函数原型，方便格式化字符串
//==========================================================================================
// 例子:
// var shareLink = '/branches/{branch_id}/orders/invitation/{order_id}'.supplant({
//   branch_id: $scope.branch_id,
//   order_id: $scope.order_id
// });
String.prototype.supplant = function (o) {
  return this.replace(/{([^{}]*)}/g,
    function (a, b) {
      var r = o[b];
      return typeof r === 'string' || typeof r === 'number' ? r : a;
    }
  );
};


// 播放消息声音
function soundPlay() {
  var playTimes = 1;
  var host = $("#sound").data("host")
  var ogg_url = host + 'audios/order_placed.ogg'
  var mp3_url = host + 'audios/order_placed.mp3'
  var media = null;
  try{
    media = new Audio(ogg_url);
  }catch(e){
    media = new Audio(mp3_url);
  }
  media.controls = "controls";
  var playAudio = function(){
    if(--playTimes==0){
      media.removeEventListener("ended", playAudio);
      return;
    }
    media.play();
  }
  media.addEventListener("ended",playAudio);
  var soundDiv = $("#sound");
  soundDiv.innerHTML = "";
  soundDiv.append(media);
  media.play();
}

// sec 为时间点秒数
function wait_time(start_seconds, end_seconds){
  if(!end_seconds){
    var end_seconds = parseInt(new Date().getTime() / 1000);
  }
  var sec = end_seconds - start_seconds;
  var hour_mod = sec % 3600;
  var hour = (sec - hour_mod) / 3600;
  var minute_mod = hour_mod % 60;
  var minute = (hour_mod - minute_mod) / 60;
  var second = minute_mod
  var l2 = function(i){return (""+i).length == 2 ? ""+i : "0"+i}
  return "{h}:{m}:{s}".supplant({h:l2(hour), m:l2(minute), s:l2(second)})
}


// local storage
var ls_version_key = 'ls_ddb_version';

function set_ddb_cache(k, v){
  var key = '__ddb_'+k;
  localStorage.setItem(key, JSON.stringify(v))
}

function get_ddb_cache(k){
  var version = localStorage.getItem(ls_version_key)
  if(version != ls_version){
    clear_ddb_cache();
    localStorage.setItem(ls_version_key, ls_version)
    return null;
  }

  var key = '__ddb_'+k;
  var v = localStorage.getItem(key)
  if(v == null) {
    return v
  }else{
    return JSON.parse(v)
  }
}

function clear_ddb_cache(){
  $.each(localStorage, function(k, v){
    if(k.match(/__ddb_/)){
      localStorage.removeItem(k);
    }
  })
}

// mask
var mask_num = 0;
function showLoadingMask(){ mask_num++; $('#ddb-loading').show(); }
function hideLoadingMask(){ if(mask_num > 0){ mask_num -- }; if(mask_num == 0){$('#ddb-loading').hide();}}
function clearLoadingMask(){ mask_num=0; $('#ddb-loading').hide();}

var Hotkey = function(){
  this.code = function(key){
    return ({
      F1 : 112, '←': 37,
      F2 : 113, '↑': 38,
      F3 : 114, '→': 39,
      F4 : 115, '↓': 40,
      F5 : 116,
      F6 : 117, '*': 106,
      F7 : 118, '+': 107,
      F8 : 119, '-': 109,
      F9 : 120,
      F10: 121,
      F11: 122, esc : 27,
      F12: 123, enter : 13,
    })[key];
  }

  this.actions = {ctrl: {}};
  //desc {:key, :action, :leader}
  this.bind = function(desc){
    if(desc.leader){
      this.actions[desc.leader][this.code(desc.key)] = desc.action;
    }else{
      this.actions[this.code(desc.key)] = desc.action;
    }
    var __hotkey = this;
    return function(){
      //console.log('unbind: '+desc.key)
      __hotkey.bind(
        {
          key: desc.key,
          action: undefined,
          leader: desc.leader
        }
      )
    }
  }

  this.trigger = function(event){
    var keycode = event.keyCode;
    var action = null;
    if(17 != keycode && event.ctrlKey){
      action = this.actions.ctrl[keycode]
    }else{
      action = this.actions[keycode]
    }
    if(action){
      if(false == action()){
        event.preventDefault();
        return false;
      }
    }
    return true
  }
}
var hotkey_p1 = new Hotkey();
var hotkey_p2 = new Hotkey();
var hotkey_p3 = new Hotkey();

var UrlParser = (function(){
    function parseQueryParameter(url){
        url = url||window.location.href;
        var link =  $('<a>', {href: url})[0];
        var query_parameter = link.search;
        var result = {};
        if(query_parameter){
            // split up the query string and store in an associative array
            var params = query_parameter.slice(1).split("&");
            for (var i = 0; i < params.length; i++)
            {
                var tmp = params[i].split("=", 2);
                result[decodeURIComponent(tmp[0])] = decodeURIComponent(tmp[1]);
            }
        }
        return result;
    }

    var each_parameter = function(handler, url){
      var result = parseQueryParameter(url);
      handler = handler || function(){};
      for (var key in result){
        handler(key, result[key]);
      }
    }

    var query_parameter = function(key){
        var result = parseQueryParameter(window.location.href);
        if(key){
            return result[key];
        }else{
            return result;
        }
    }

    var page_url_without_query =function(){
        return window.location.origin + window.location.pathname;
    }
    var change_parameter = function(url, key, value){
        var result = parseQueryParameter(url);
        var link = $('<a>', {href: url})[0];
        result[key] = value;
        link.search = '?';
        for(var i in result){
            if(link.search.length > 1) {
                link.search += '&';
            }
            if(result[i]){
                link.search += i+"="+result[i];
            }
        }
        return link.href;
    }

     return {
        query_parameter: query_parameter,
        page_url_without_query: page_url_without_query,
        change_parameter: change_parameter,
        each_parameter: each_parameter
     }
}());

function scroll_up(e){
  var scroll = $(".scroll-wrapper", $(e).parent()).data("scroll");
  scroll.maxScrollY
  var y = scroll.y + 200;
  if(y > 0){ y = 0 }
  if(scroll){ scroll.scrollTo(0, y, 500);}
}

function scroll_down(e){
  var scroll = $(".scroll-wrapper", $(e).parent()).data("scroll");
  var y = scroll.y - 200;
  if(y < scroll.maxScrollY){ y = scroll.maxScrollY }
  if(scroll){ scroll.scrollTo(0, y, 500);}
}
