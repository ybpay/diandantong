var Base = {}
Base.template_folder = "/weixin/client_partials";
Base.weixin_page_templates_folder = "/weixin/weixin_page_templates/";
Base.template_path = Base.template_folder + '/';
Base.config = {}
Base.requires = [
  'ngRoute',
  'ngResource',
  'ngSanitize',
  'rn-lazy',
  'errorReporter',
  'ngIOS9UIWebViewPatch',
  'ddt_app.constants',
  'ddt_app.filters.filter',
  'ddt_app.directives.include-replace',
  'ddt_app.directives.modal',
  'ddt_app.services.history_url',
  'ddt_app.controllers.rounte_not_found',
];

Base.config.interceptors = ['$httpProvider', '$sceDelegateProvider', 'DdtConst', function($httpProvider, $sceDelegateProvider, DdtConst){
  $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
  $httpProvider.defaults.headers.post["Content-Type"] = "application/json";

  // support load templates from CDN
  $sceDelegateProvider.resourceUrlWhitelist([
    // Allow same origin resource loads.
    'self',
    // Allow loading from outer templates domain.
    DdtConst.cdn_cache_domain + '/**'
  ]);

  var request_interceptor = ['$rootScope', '$q', 'DdtConst',
    function ($rootScope, $q, DdtConst) {
      return {
        'request': function(config){
          if (config.url.indexOf(Base.template_path) == 0) {
            // 页面模板请求
            if($rootScope.env !== 'development'){
              config.url = DdtConst.cdn_cache_domain + config.url;
            }
          }else{
            config.params = config.params || {}
            config.params.format = 'json';
            config.params.version = version_timestamp;
          }
          return config;
        }
      };
    }];

  var mask_interceptor = ['$rootScope', '$q', function($rootScope, $q) {
    return {
      'request' : function(config){
        if(!(config.params && config.params.nomask)){
          showLoadingMask()
        }
        return config;
      },
      'response': function(response){
        if(!(response.config.params && response.config.params.nomask)) {
          hideLoadingMask()
        }
        return response;
      }
    }
  }]

  //监听错误响应
  var interceptor = ['$rootScope', '$q', function (scope, $q) {
    function error(response) {
      if (response.status == 400) {
          scope.is_submiting = false
          var deferred = $q.defer();
          if(response.data.custom){
            scope.$emit("events:bad_request:custom", response.data)
          }else{
            if(response.data.error){
              scope.$emit("events:receive_errors", response.data.error);
            }else if(response.data.errors){
              scope.$emit("events:receive_errors", response.data.errors);
            }else{
              scope.$emit("events:receive_errors", response.data);
            }
          }

          if(!(response.config.params && response.config.params.nomask)){ hideLoadingMask();}
          return deferred.promise;
      }
      return $q.reject(response);
    }
    return {
      'responseError' : error
    }
  }];

  $httpProvider.interceptors.push(request_interceptor);
  $httpProvider.interceptors.push(interceptor);
  $httpProvider.interceptors.push(mask_interceptor);
}]


Base.config.routes = ['$routeProvider', 'RouteConfigProvider',
  function($routeProvider, RouteConfigProvider) {
  var all_configs = RouteConfigProvider.$get().get()
  var weixin_pages = JSON.parse($('meta[name="weixin_pages_json"]').attr("content")||'[]');
  angular.forEach(all_configs, function(conf){
    var route = {controller: conf.controller, feature: conf.feature};
    if(conf.templateUrl){
      route.templateUrl = Base.template_folder + conf.templateUrl + version_timestamp
      for(var i =0 ; i < weixin_pages.length; i ++ ){
       var weixin_page = weixin_pages[i];
       if(weixin_page.template_type == conf.templateUrl){
        route.templateUrl = Base.weixin_page_templates_folder + weixin_page.url + version_timestamp
        console.log("为"+conf.templateUrl+"配置了自定义页面"+ weixin_page.url);
        break;
       }
      }
    }else{
      route.template = conf.template;
    }
    $routeProvider.when(conf.path, route)
  });
  $routeProvider.otherwise({
    template: '<div class="weui_msg main-view">' +
      '<div class="weui_icon_area"><i class="weui_icon_warn weui_icon_msg"></i></div>' +
      '<div class="weui_text_area">' +
        '<h2 class="weui_msg_title">哎呀！迷路了</h2>' +
        '<p class="weui_msg_desc">等待3秒后跳转至首页</p>' +
      '</div>' +
    '</div>',
    controller: 'routeNotFoundController'
  });
}]


Base.config.location = ['$locationProvider', function($locationProvider) {
  $locationProvider.html5mode = true
  $locationProvider.hashPrefix = '!';
}]

Base.go = function(page, path){
  var link = $('<a>', {href: window.location.href})[0];
  var path_strs = link.pathname.split('/');
  if(page){
    path_strs[4] = page;
  }else if(path_strs.length > 4){
    path_strs.splice(4)
  }
  link.pathname = path_strs.join('/');
  link.hash = path;
  url = UrlParser.change_parameter(link.href, '_ng_path', path);
  window.location.href = url;
}

Base.init = function($rootScope, $route, $location, DdtConst, HistoryUrlService, WechatShareRecordService, UserService){
  Base.cdn_cache_domain = DdtConst.cdn_cache_domain;
  $rootScope.env = DdtConst.env;
  $rootScope.Math = Math;
  $rootScope.is_submiting = false;

  UserService.get(function(user){
    $rootScope.user = user
  })

  $rootScope.go     = function(url, is_store){ HistoryUrlService.go(url, is_store)}
  $rootScope.go_page= function(page, path, is_store){
    var pathname = window.location.pathname;
    var path_strs = pathname.split('/');
    if(page && page.length > 0){
      if(path_strs[4] == page){
        HistoryUrlService.go(path, is_store)
      }else{
        Base.go(page, path);
      }
    }else if(!path_strs[4] || path_strs[4].length == 0){
      HistoryUrlService.go(path, is_store)
    }else{
      Base.go(undefined, path);
    }

    if(path_strs[4] == page){
      HistoryUrlService.go(path, is_store)
    }else {
      path_strs[4] = path;
      var link = $("<a>", {href: window.location.href});
      link.pathname = path_strs.join('/')
    }
  };
  $rootScope.tag_in_branch = function(tag_id, branch){
    if(!branch || !branch.tags){
      return undefined;
    }
    for(var i = 0; i < branch.tags.length; i ++ ){
      if(branch.tags[i].id == tag_id){
        return branch.tags[i];
      }
    }
    return undefined;
  }
  $rootScope.has_feature = function(key){
    if(!$rootScope.shop){return true}
    if(!$rootScope.shop.features){return true}
    if($rootScope.shop.features.length == 0){return true}
    return $rootScope.shop.features.indexOf(key) > -1
  }
  $rootScope.back   = function(){ HistoryUrlService.back()}
  $rootScope.reload = function(){ $route.reload()}
  $rootScope.clear_history_url   = function(){ HistoryUrlService.clear_history_url()}

  $rootScope.partial = function(partial_name){
    return Base.template_path + partial_name + ".html" + version_timestamp;
  }

  $rootScope.directive_partial = function(directive_partial_name){
    return $rootScope.partial('directives/' + directive_partial_name);
  }

  $rootScope.img_url = function(path){
    return DDBUtil.makeAssetUrl(path, DdtConst, true)
  }

  $rootScope.alert = function(error){
    $rootScope.$emit("events:receive_errors", error)
  }

  $rootScope.toast = function(info){
    $rootScope.$emit("events:success_info", info)
  }

  $rootScope.confirm = function(title, content, confirm_callback, confirm_text, cancel_callback, cancel_text){
    $rootScope.confirm_modal = {
      title        : title,
      content      : content,
      confirm      : function(){ $rootScope.confirm_modal.show = false; if(confirm_callback){ confirm_callback() };},
      confirm_text : confirm_text || "确定",
      cancel       : function(){ $rootScope.confirm_modal.show = false; if(cancel_callback){ cancel_callback() };},
      cancel_text  : cancel_text || "取消",
      show         : true
    }
  }


  $rootScope.$watch('title', function(new_value, old_value){
    if(new_value!=old_value){
      $('title').html(new_value);
    }
  })

  $rootScope.show_base_menu = function(){
    //wx.hideAllNonBaseMenuItem();
    wx.hideMenuItems({
      menuList: [
        // "menuItem:copyUrl",
        "menuItem:originPage",
        // "menuItem:refresh",
        "menuItem:share:appMessage",
        "menuItem:share:timeline",
        "menuItem:share:qq",
        "menuItem:share:weiboApp",
        // "menuItem:favorite",
        "menuItem:share:facebook",
        "menuItem:share:QZone",
      ]
    })
  }

  $rootScope.show_share_menu = function(){
    wx.hideAllNonBaseMenuItem()
    wx.showMenuItems({
      menuList: [
        "menuItem:share:appMessage",
        "menuItem:share:timeline",
        "menuItem:share:qq",
        "menuItem:share:weiboApp"
      ]
    })
  }
  if($rootScope.hide_menu_default){wx.ready($rootScope.show_base_menu)}
  $rootScope.$on('$routeChangeStart', function(event, next, current){
    var feature = next.feature
    if(feature && !$rootScope.has_feature(feature)){
      $rootScope.back();
      event.preventDefault();
      $rootScope.toast('即将推出， 敬请期待')
      return;
    }
    if($rootScope.hide_menu_default){$rootScope.show_base_menu();}
    $rootScope.title = $rootScope.current_shop.name
    if(HistoryUrlService.is_back_url($location.url())){ clearLoadingMask();}
    HistoryUrlService.push_current_url();
    $(document).off('scroll');
  })


  $rootScope.$on('$routeChangeSuccess', function(event, current, previous){
    $rootScope.shareRecordTrigger = {
      triggerBeforeCreateRecord: null,
      triggerBeforeCommitRecord: null
    }
  })

  $rootScope.$on("events:receive_errors", function(e, error, time){
    if(error instanceof Array){
      $rootScope.alert_content = error.join(", ");
    }else{
      $rootScope.alert_content = error;
    }
    setTimeout(function(){
      $rootScope.$apply(function(){
        $rootScope.alert_content = undefined;
      });
    },time||4000);
  });

  $rootScope.$on("events:success_info", function(e, info, time){
    $rootScope.toast_content = info;
    setTimeout(function(){
      $rootScope.$apply(function(){
        $rootScope.toast_content = undefined;
      });
    },time||4000);
  });

  $rootScope.go_ng_path = function(default_action){
    var path = UrlParser.query_parameter('_ng_path')
    // 发现备用路由参数，而且丢失路径，跳转之。
    if(['/', ''].indexOf($location.path()) >= 0){
      if(path){
        $location.url(path);
      }else{
        if(default_action){
          default_action();
        }
      }
    }
  }

  if(WechatShareRecordService){
    $rootScope.bind_wechat_share_callback = function(){
      var successShare = function(resp, wxShareConfig){
        wxShareConfig.share_type = resp.share_type;
        if ($rootScope.shareRecordTrigger.triggerBeforeCommitRecord) {
          $rootScope.shareRecordTrigger.triggerBeforeCommitRecord(resp, wxShareConfig);
        }
        WechatShareRecordService.update(wxShareConfig);
      }

      var triggerShare = function(resp, wxShareConfig) {
        var trigger_timestamp = new Date().getTime();

        wxShareConfig.imgUrl = $rootScope.shop.image;
        wxShareConfig.link = UrlParser.page_url_without_query();
        wxShareConfig.link = UrlParser.change_parameter(wxShareConfig.link, 'wechat_share_record_trigger_timestamp', trigger_timestamp);
        wxShareConfig.desc = $rootScope.shop.introduction || '账号介绍';
        wxShareConfig.title = $rootScope.shop.name || '微信点单';
        wxShareConfig.link = UrlParser.change_parameter(wxShareConfig.link, '_ng_path', $location.path());
        wxShareConfig.link = UrlParser.change_parameter(wxShareConfig.link, '_share_user_id', $rootScope.user.id);

        if ($rootScope.shareRecordTrigger.triggerBeforeCreateRecord) {
          $rootScope.shareRecordTrigger.triggerBeforeCreateRecord(resp, wxShareConfig);
        }
        //经测试,微信不允许trigger内再调用异步修改link，故我们先设置好分享信息，再索取分享id信息，以便分享成功后进行更新
        WechatShareRecordService.create_id(trigger_timestamp, function(resp){
          wxShareConfig.id = resp.id;
        });
      }
      WeixinApi.bindShareCallback(triggerShare, successShare);
    }
  }


  return $rootScope;
}

Base.newBtns = function(_location){
  var btns = [];
  btns.location = _location;
  btns.push = function(item){
    item.location = this.location;
    if(item.img){
      item.img = DDBUtil.makeCdnUrl(item.img, Base.cdn_cache_domain, true)
    }
    item.click = function(){
      if(item.href){
        item.location.path(item.href);
      }else if(item.page){
        window.location.href = item.page;
      }else if(item.func){
        item.func();
      }
    }
    this[this.length] = item
  }
  btns.group = function(_size){
    var size = _size || 4
    return group_in(this, size)
  }
  return btns;
}