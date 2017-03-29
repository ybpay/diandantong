WebposModules.add_service('wallet_log');
angular.module('webpos.services.wallet_log', []).
  factory('WalletLogService', ['$resource', function($resource) {
    // 为了使用PaginateService，重新包装一个新的service。
    var VipInfo = $resource('/vip_infos/:vip_info_id/:action', {}, {
      wallet_logs: {method: 'get', params: {action: 'wallet_logs'}, isArray: true}
    });

    var query = function(params, success) {
      VipInfo.wallet_logs(params, success);
    }

    return {
      query: query
    }
  }]);
