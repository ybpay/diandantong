WebposModules.add_service('voucher');
angular.module('webpos.services.voucher', []).
  factory('VoucherService', ['$resource', function($resource){

    var Voucher = $resource("/branches/:branch_id/vouchers/:voucher_id/:action", {}, {
      search:    { method: 'get', params: { action: 'search'}},
      available: { method: 'get', params: { action: 'available'}, isArray: true},
      exchange_by_id:   { method: 'post',params: { action: 'exchange_by_id'}},
      find_by_code: { method: 'post', params: { action: 'find_by_code'}},
      exchange_by_code: { method: 'post', params: {action: 'exchange_by_code'}}
    })

    function search(branch_id, code, success){
      Voucher.search({ branch_id: branch_id, code: code }, success)
    }

    var available = function(branch_id, user_id, success){
      Voucher.available({branch_id: branch_id, user_id: user_id}, success);
    }

    var exchange_by_id = function(branch_id, user_id, voucher_id, success){
      Voucher.exchange_by_id({branch_id: branch_id, voucher_id: voucher_id},{user_id: user_id}, success);
    }

    var find_by_code = function(branch_id, exchange_code, success){
      Voucher.find_by_code({branch_id: branch_id}, {exchange_code: exchange_code}, success)
    }

    var exchange_by_code = function(branch_id, voucher_id, success){
      Voucher.exchange_by_code({branch_id: branch_id}, {base_coupon_id: voucher_id}, success)
    }

    return {
      search: search,
      available: available,
      exchange_by_id: exchange_by_id,
      find_by_code: find_by_code,
      exchange_by_code: exchange_by_code
    }
  }])
