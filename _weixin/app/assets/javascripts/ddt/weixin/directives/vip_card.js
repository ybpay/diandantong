Ddt.directive('vipCard', [
  function () {
  return {
    restrict: 'EA',
    scope: {
      user: '=ngUser',
      shop: '=ngShop'
    },
    replace: true,
    template:
                '<div class="user-banner">' +
                  '<div class="card">' +
                    '<div class="avatar">' +
                      '<img width="80%" ng-src="{{shop.vip_logo}}" ng-show="shop.vip_logo">' +
                      '<span ng-hide="shop.vip_logo" class="logo-name">{{shop.name}}</span>' +
                    '</div>' +
                    '<div class="vip-info">' +
                      '<div class="headimg">' +
                        'ID {{user.id}}' +
                      '</div>' +
                      '<div class="label">' +
                        '会员卡号' +
                      '</div>' +
                      '<div class="value">' +
                        '<span ng-if="user.is_vip">{{user.vip_info.vip_no}}</span>' +
                        '<span ng-if="!user.is_vip">非会员</span>' +
                      '</div>' +
                    '</div>' +
                  '</div>' +
                '</div>',
    link: function(scope, element, attrs) {}
  }
}]);
