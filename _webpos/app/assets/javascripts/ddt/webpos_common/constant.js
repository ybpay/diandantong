var WebposConst = (function(){
  function get_meta(name){
    return $('meta[name=' + name +']').attr('content');
  }

  return {
    login_path: "/accounts/sign_in",
    env: get_meta('env'),
    account: JSON.parse(get_meta('account')),
    per_page: 20,
    cdn_cache_domain: get_meta('cdn_cache_domain') || ""
  }
})();

angular.module('webpos.constants', []).constant('WebposConst', WebposConst);
