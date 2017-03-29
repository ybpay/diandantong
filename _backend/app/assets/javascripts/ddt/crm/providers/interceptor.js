CrmModules.add('interceptor')
angular.module('crm.interceptor',[]).
  provider('Interceptor', ['$sceDelegateProvider',
  function($sceDelegateProvider){

    $sceDelegateProvider.resourceUrlWhitelist([
      // Allow same origin resource loads.
      'self',
      // Allow loading from outer templates domain.
      CrmConst.cdn_cache_domain  + '/**'
    ]);

    this.$get = function(){
      var all_interceptors = [];

      var request_interceptor = ['$q', "$rootScope", function ($q, $rootScope) {
        function request(config) {
          var canceler = $q.defer();
          config.timeout = canceler.promise;
          if(config.url.indexOf('/backend/crm/templates/') == 0){
            // 页面模板请求
            if(CrmConst.env !== "development"){
              config.url = CrmConst.cdn_cache_domain + config.url;
            }
          }else{
            // 普通请求
            config.params = config.params || {}
            config.params.format = 'json'
            if(config.method != "get"){
              if($rootScope.is_requesting && $rootScope.last_request_url == config.url){
                // console.log("request stop")
                // console.log(config)
                canceler.resolve();
              }else{
                $rootScope.is_requesting = true
                $rootScope.last_request_url = config.url
              }
            }
          }
          // console.log(config)
          return config
        }

        return {
          'request' : request
        }
      }];

      var response_interceptor = ['$rootScope', '$q', "$timeout", function ($rootScope, $q, $timeout) {
        function response(response) {
          if(response.config.method != "get"){
            $timeout(function(){
              $rootScope.is_requesting = false
            }, 500)
          }
          return response
        }
        return {
          'response' : response
        }
      }];

      var error_interceptor = ['$rootScope','$q', function ($rootScope, $q) {
        function error(response) {
          NProgress.done();
          if (response.status == 400 || response.status == 401) {
            hideLoadingMask()
            var errors = response.data.error || response.data.errors || response.data.info || response.data.message || response.data
            $rootScope.alert(errors)
            if(response.data.file_upload_response){
              return $q.reject(response);
            }else{
              var deferred = $q.defer();
              return deferred.promise;
            }
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
      add_interceptor(mask_interceptor)
      add_interceptor(response_interceptor)

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
