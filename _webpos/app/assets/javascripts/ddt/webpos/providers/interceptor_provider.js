angular.module('webpos.interceptor',[]).
  provider('Interceptor', ['$sceDelegateProvider',
  function($sceDelegateProvider){

    $sceDelegateProvider.resourceUrlWhitelist([
      // Allow same origin resource loads.
      'self',
      // Allow loading from outer templates domain.
      WebposConst.cdn_cache_domain  + '/**'
    ]);

    this.$get = function(){
      var all_interceptors = [];

      var request_interceptor = ['$rootScope', '$q', function ($rootScope, $q) {
        function request(config) {
          if(config.url.indexOf('/webpos/partials/') == 0){
            // 页面模板请求
            //if($rootScope.env !== "development"){
            //  config.url = WebposConst.cdn_cache_domain + config.url;
            //}
          }else{
            // 普通请求
            config.params = config.params || {}
            config.params.terminal_id = $rootScope.terminal_id;
            config.params.format = 'json'
            config.params.authorizer_id = $rootScope.current_authorizer_id();
            config.headers['Server-Mode'] = 'online';
            if(["/webpos/webpos_accounts/sign_in",
                "/webpos/webpos_accounts/sign_out",
                "/webpos/account",
                "/webpos/account/bosses_and_workers",
                "/webpos/account/authorization",
                "/webpos/account/get_authorizers",
                "/sync/switchOffline",
                "/sync/switchOnline",
                "/sync/isLocalServer",
                "/sync/pushAndUpdate"
              ].indexOf(config.url) !== -1){
              // 登陆 或 注销 或 授权
            }else{
              // 其他
              config.url = $rootScope.base_url() + config.url
            }
          }
          // console.log({method: config.method, cache: config.cache, url: config.url})
          return config
        }

        return {
          'request' : request
        }
      }];

      var response_interceptor = ['$rootScope', '$q', function ($rootScope, $q) {
        function response(response) {
          console.log(response)
          return response
        }
        return {
          'response' : response
        }
      }];


      var error_interceptor = ['$rootScope', '$q', function ($rootScope, $q) {
        function error(response) {
          hideLoadingMask();
          if (response.status == 400 || (response.status == 401 && is_login_path())) {
            $rootScope.is_submiting = false
            var deferred = $q.defer();
            var errors = response.data.error || response.data.errors || response.data.info || response.data
            $rootScope.alert(errors)
            return deferred.promise;
          }else if (response.status == 422) {
            var deferred = $q.defer();
            $rootScope.alert("由于长时间未操作，该网页已过期，请刷新重试！");
            return deferred.promise;
          }
          else if (response.status == 499){
            var deferred = $q.defer();
            var errors = response.data.error || response.data.errors || response.data.info || response.data
            alert(errors);
            window.location.reload();
            return deferred.promise;
          } else if (/* remote server down */ response.status == 599 || /*legacy*/ response.status == 510) {
            var deferred = $q.defer();
            window.location.href = response.data.url
            return deferred.promise;
          }
          else if (response.status == 502 || response.status == 0 /* conn error */){
            var deferred = $q.defer();
            if (typeof BrowserFormObject != 'undefined') {
              BrowserFormObject.notify_conn_error();
              deferred.reject(response)
            } else {
              deferred.reject(response)
            }
            return deferred.promise;
          } else {
            var deferred = $q.defer()
            deferred.reject(response)
            return deferred.promise;
          }
        }

        return {
          'responseError' : error
        }
      }];

      var login_require_interceptor = ['$rootScope', '$q', function ($rootScope, $q) {
        function error(response) {
          hideLoadingMask();
          if (response.status == 401 && !is_login_path()) {
            var deferred = $q.defer();
            $rootScope.$broadcast('event:loginRequired');
            return deferred.promise;
          }
          return $q.reject(response);
        }
        return {
          'responseError' : error
        }
      }];

      var no_mask_urls = ["/tables/get_changed_tables", "/orders/pending_counts"]
      function need_mask(config){
        if($.grep(no_mask_urls,function(url){return config.url.indexOf(url) >= 0}).length > 0){
          return false
        }
        if(config.params && config.params.skip_mask){
          return false
        }
        return true
      }
      var mask_interceptor = ['$rootScope', '$q', function($rootScope, $q) {
        return {
          'request' : function(config){
            if(need_mask(config)){ showLoadingMask(); }
            return config;
          },
          'response': function(response){
            if(need_mask(response.config)){ hideLoadingMask();}
            return response;
          }
        }
      }]

      add_interceptor(request_interceptor);
      // add_interceptor(response_interceptor);
      add_interceptor(error_interceptor);
      add_interceptor(login_require_interceptor);
      add_interceptor(mask_interceptor)

      function get(){
        return all_interceptors;
      }

      function add_interceptor(interceptor){
        all_interceptors.push(interceptor);
      }

      function is_login_path(){
        return window.location.hash.indexOf(WebposConst.login_path) != -1
      }

      return {
        get: get
      }
    }
  }]);
