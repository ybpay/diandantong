"use strict";
var version_timestamp = "?201612170152";


// 为了令微信支付正常工作，对不带查询参数和的 URL 强制加上空查询 '?'
(function(){
    if (window.location.search == ""){
        var href = window.location.href;
        var idx = href.indexOf('#');
        if (idx != -1) {
            if (href.lastIndexOf('?', idx) == -1) {
                window.location.href = href.substring(0, idx) + '?' + href.substring(idx);
            }
        }else{
            if (href.lastIndexOf('?') == -1) {
                window.location.href = href + '?';
            }
        }
    }
})();

//==========================================================================================
// 添加 String 函数原型，方便格式化字符串
//==========================================================================================

String.prototype.supplant = function (o) {
  return this.replace(/{([^{}]*)}/g,
    function (a, b) {
      var r = o[b];
      return typeof r === 'string' || typeof r === 'number' ? r : a;
    }
  );
};

var mask_num = 0;
var mask_id = '#loadingToast'
function showLoadingMask(){ mask_num++; $(mask_id).show(); }
function hideLoadingMask(){ if(mask_num > 0){ mask_num -- }; if(mask_num == 0){$(mask_id).hide();}}
function clearLoadingMask(){ mask_num=0; $(mask_id).hide();}
function touchScroll(selector){
    var scrollStartPos = 0;
    $(selector).on('touchstart', function(event) {
        if(event.originalEvent){
            scrollStartPos = this.scrollTop + event.originalEvent.touches[0].pageY;
        }else{
            scrollStartPos = this.scrollTop + event.touches[0].pageY;
        }
    });
    $(selector).on('touchmove', function(event) {
        if(event.originalEvent){
            this.scrollTop = scrollStartPos - event.originalEvent.touches[0].pageY;
        }else{
            this.scrollTop = scrollStartPos - event.touches[0].pageY;
        }
    });
}


function group_in(item_list, size, need_fill){
  var item_length = item_list.length;
  if(typeof need_fill == 'undefined'){
    need_fill = true;
  }
  for(var i = 0 ; need_fill && item_length % size != 0 && i < size - (item_length % size); i ++ ){
    item_list.push({});
  }
  var list = [];
  var sub_list = [];
  for(var i = 0; i <  item_list.length ; i ++ ){
    sub_list.push(item_list[i]);
    if(sub_list.length == size || i == item_list.length-1) {
      list.push(sub_list);
      sub_list = [];
    }
  }
  console.log(list);
  return list;
}

$(document).ready(function(){
    $(document).on('touchmove', '.ddb-box', function(e){
        e.preventDefault();
    });
});

window.addEventListener('load', function() {
    FastClick.attach(document.body);
}, false);

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


//==========================================================================
// angular 定义辅助函数
//==========================================================================
(function(){

    // 点单通模块，angular 模块的包装类
    var DdtModule = function (moduleName, ngModule) {
        this.ngModule = ngModule;
        this.moduleName = moduleName;

        // 定义代理函数
        for (var key in this.ngModule){
            var func = this.ngModule[key];
            if (typeof func == 'function') {
                var This = this;
                this[key] = new function () {
                    var f = func;
                    return function(){
                        f.apply(This.ngModule, arguments);
                        return This;
                    }
                }
            }
        }
    };


    var Ddt = {
        // 记录目前已经创建的模块，以便创建 ddt_app
        modules: {},

        // 创建模块
        module: function(name, dependencies){
            var ddbModule = this.modules[name];
            if (dependencies != 'undefined'){
                var ngModule = angular.module(name, dependencies);
                var ddbModule = new DdtModule(name, ngModule);
                this.modules[name] = ddbModule;
            }
            return ddbModule;
        },

        // 构建 Ddt app 的依赖
        buildAppDependencies: function(extraDependencies){
            var dependencies = [].concat(extraDependencies);
            for (var name in this.modules){
                dependencies.push(name);
            }
            return dependencies;
        },

        // 从对象名称推断模块名字
        inferModuleName: function(name){
            var type = /(Service|Factory|Controller|Directive)$/.exec(name)
            var prefix;
            var postfix;
            if (type != null){
                type = type[0];
                prefix = pluralize(type.toLowerCase());
                postfix = name.substr(0, name.length - type.length).toLowerCase();
                postfix = pluralize(postfix,1);
            }else{
                prefix = "miscellanies";
                postfix = pluralize(name,1);
            }
            return "ddt_app." + prefix + "." + postfix;
        }
    };


    // 因为代码压缩的原因，不能通过名称的匹配来定义

    // 支持简捷声明的原语
    var SUPPORT_TERMINOLOGY = ['service', 'factory', 'controller', 'directive'];
    // Shotcut Methods
    // 以下函数可以更方便地定义 factory controller 和 service
    $.each(SUPPORT_TERMINOLOGY, function(i, type){
        Ddt[type] = function(){
            var ngType = type;
            var moduleName;
            var objectName;
            var dclArray;
            switch (arguments.length) {
                case 2:
                    objectName = arguments[0];
                    moduleName = Ddt.inferModuleName(objectName);
                    dclArray = arguments[1];
                    break;
                case 3:
                    moduleName = arguments[0];
                    objectName = arguments[1];
                    dclArray = arguments[2];
                    break;
                default:
                    throw 'illegal argument length: ' + arguments.length, arguments;
            }
            return Ddt.module(moduleName, [])[ngType](objectName, dclArray);
        }
    });
    window.Ddt = Ddt;


  window.DDBUtil = {
    findFirstAvatar: function(){
      return $("img").filter(function(i, e){
        // fetch first image that pixel >= 200x200
        var elem = $(e);
        if (elem.width() >= 300 && elem.height() >= 300){
          return true;
        }else{
          return false;
        }
      }).first();
    },
    makeAssetUrl: function(localAssetUrl, DdtConst, absolute){
      var cdn_cache_domain = DdtConst.cdn_cache_domain;
      return this.makeCdnUrl(localAssetUrl, cdn_cache_domain, absolute)
    },
    makeCdnUrl: function(localAssetUrl, cdn_cache_domain, absolute){
      if (localAssetUrl && localAssetUrl.length > 0 && localAssetUrl[0] == '/'){
        if (cdn_cache_domain){
          return cdn_cache_domain + localAssetUrl;
        }else if (absolute){
          return window.location.origin + localAssetUrl;
        } else {
          return localAssetUrl;
        }
      }else{
        // null or absolute path
        return localAssetUrl;
      }
    }
  };
})(window.jQuery||window.Zepto);
