WebposModules.add_service('user_wallet');
angular.module('webpos.services.user_wallet',[]).
  factory("UserWalletService", ["$resource", function($resource){

    var CreditsWallet = $resource('/user_credits_wallets/:id/:action',{},{
      exchange: {method: 'post', params: {action: 'exchange'}}
    });

    var CardWallet = $resource('/user_card_wallets/:id/:action',{},{
      recharge: {method: 'post', params: {action: 'recharge'}},
      exchange: {method: 'post', params: {action: 'exchange'}}
    });


    var card_recharge = function(wallet, recharge, success){
      var recharge_params = {amount: recharge.actually_amount, cash_amount: recharge.amount, note: recharge.note, branch_id: recharge.branch_id }
      CardWallet.recharge({id: wallet.id}, {recharge: recharge_params}, function(response){
        success(response.card_wallet)
      })
    }
    var card_exchange = function(wallet, exchange, success){
      CardWallet.exchange({id: wallet.id}, {exchange: exchange}, function(response){
        success(response.card_wallet)
      })
    }
    var credits_exchange = function(wallet, exchange, success){
      CreditsWallet.exchange({id: wallet.id}, {exchange: exchange}, function(response){
        success(response.card_wallet)
      })
    }

    return {
      card_recharge: card_recharge,
      card_exchange: card_exchange,
      credits_exchange: credits_exchange
    }

  }])
