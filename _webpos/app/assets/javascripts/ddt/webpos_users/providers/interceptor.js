WebposModules.add('interceptor')
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

      var request_interceptor = ['$q', '$rootScope', function ($q, $rootScope) {
        function request(config) {
          if(config.url.indexOf('/webpos/templates') == 0 || config.url.indexOf('/webpos/partials') == 0){
            // 页面模板请求
            //if(WebposConst.env !== "development"){
            //  config.url = WebposConst.cdn_cache_domain + config.url;
            //}
          }else{
            // 普通请求
            config.params = config.params || {}
            config.params.format = 'json'
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
          // console.log(config)
          return config
        }

        return {
          'request' : request
        }
      }];

      var error_interceptor = ['$rootScope','$q', function ($rootScope, $q) {
        function error(response) {
          hideLoadingMask();
          if (response.status == 400) {
            $rootScope.is_submiting = false
            var deferred = $q.defer();
            var errors = response.data.error || response.data.errors || response.data.info || response.data
            $rootScope.alert(errors)
            return deferred.promise;
          }else if (response.status == 422) {
            var deferred = $q.defer();
            $rootScope.alert("由于长时间未操作，该网页已过期，请刷新重试！");
            return deferred.promise;
          }else if (response.status == 510) {
            var deferred = $q.defer();
            window.location.href = response.data.url;
            return deferred.promise;
          } else {
            return $q.reject(response);
          }
        }

        return {
          'responseError' : error
        }
      }];

      var login_require_interceptor = ['$rootScope', '$q', function ($rootScope, $q) {
        function error(response) {
          hideLoadingMask();
          if (response.status == 401) {
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

      var no_mask_urls = ["/path/that/no/mask"]
      var in_mask_url = function(config_url){
        return $.grep(no_mask_urls,function(url){
          return config_url.indexOf(url) >= 0
        }).length === 0
      }
      var mask_interceptor = ['$q', function($q) {
        return {
          'request' : function(config){
            if(in_mask_url(config.url)){ showLoadingMask(); }
            return config;
          },
          'response': function(response){
            if(in_mask_url(response.config.url)){ hideLoadingMask();}
            return response;
          }
        }
      }]

      add_interceptor(request_interceptor);
      add_interceptor(error_interceptor);
      add_interceptor(login_require_interceptor);
      add_interceptor(mask_interceptor)

      function get(){
        return all_interceptors;
      }

      function add_interceptor(interceptor){
        all_interceptors.push(interceptor);
      }

      return {
        get: get
      }
    }
  }]);
