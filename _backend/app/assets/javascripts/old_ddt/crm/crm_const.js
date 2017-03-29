var CrmConst = (function(){
  function get_meta(name){
    return $('meta[name=' + name +']').attr('content');
  }

  return {
    env: get_meta('env'),
    shop_id: get_meta("shop_id"),
    account: JSON.parse(get_meta('account')),
    cdn_cache_domain: get_meta('cdn_cache_domain'),
  }
})();
angular.module('crm.constants', []).constant('CrmConst', CrmConst);
