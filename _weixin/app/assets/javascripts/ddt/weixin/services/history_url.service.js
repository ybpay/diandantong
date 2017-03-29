angular.module('ddt_app.services.history_url', [])
.factory('HistoryUrlService',
  ['$location', '$timeout', function ($location, $timeout) {

    var root_url = {
      url: '/',
      path: '/',
      search: {},
      hash: ''
    }
    var history_urls = [root_url];

    var is_store_next_url = true;

    function go(url, is_store){
      is_store = typeof is_store !== 'undefined' ? is_store : true;
      is_store_next_url = is_store
      if(url && url.match("^#/")){
        set_url(url.slice(1))
      }else if(url && url.match("^/")){
        set_url(url)
      }else{
        var default_protocol_prefix = "http://";
        var support_protocols = /^http|^https/;
        url = url.match(support_protocols) ? url : default_protocol_prefix + url;
        window.location.href = url;
      }
    }

    function back(){
      if(history_urls.length == 1){ history_urls.push(root_url) }
      back_url = get_back_url()
      set_url(back_url.url)
    }

    function set_url(url){
      $timeout(function(){
        $location.url(url)
      }, 50);
    }

    function push_current_url(){
      current_url    = $location.url()
      current_path   = $location.path()
      current_search = $location.search()
      current_hash   = $location.hash()
      if(is_back_url(current_url)){
        //back
        history_urls.pop()
      }else{
        if(history_urls[history_urls.length - 1].url !== current_url){
          //new url
          if(is_store_next_url && !is_grep_path(current_path)){
            history_urls.push({
              url:    current_url,
              path:   current_path,
              search: current_search,
              hash:   current_hash
            })
          }else{
            is_store_next_url = true;
          }
        }
      }
      // console.log($.map(history_urls,function(url){return url.url}))
    }

    function is_grep_path(path){
      var grep_paths = ['tables', '/edit', '/addresses/new', '/comment/new', '/new_guest',
                     '/pay_online', '/user/apply-vip', '/user/update-pay-password', '/groupon/new', '/guest_queue_qr_code', '/recharge_products']
      var is_grep = false
      angular.forEach(grep_paths, function(grep_path){
        if(!is_grep && path.match(grep_path)){
          is_grep = true
        }
      })
      return is_grep;
    }

    function get_back_url(){
      if($location.url() == history_urls[history_urls.length - 1].url){
        return history_urls[history_urls.length - 2]
      }else{
        return history_urls[history_urls.length - 1]
      }
    }

    function is_back_url(url){
      return history_urls.length >= 2 && history_urls[history_urls.length - 2].url === url
    }

    function clear_history_url(){
      history_urls = [root_url];
    }

    return {
      go:go,
      back:back,
      is_back_url:is_back_url,
      get_back_url: get_back_url,
      push_current_url:push_current_url,
      clear_history_url: clear_history_url
    }
  }]);
