angular.module('ddt_app.constants', []).constant('DdtConst', {
  env: $('meta[name="env"]').attr("content"),
  shop_slug: window.location.pathname.split("/")[3],
  baseUrl: "/weixin/shops/" + window.location.pathname.split("/")[3],
  directiveTemplateBaseUrl: '/weixin/client_partials/directives',
  oauth_user_info_url: $('meta[name="oauth_user_info_url"]').attr("content"),
  cdn_cache_domain: $('meta[name="cdn_cache_domain"]').attr("content") || "",
  wechat_account_be_verified: $('meta[name="wechat_account_be_verified"]').attr("content") == 'true'
});
