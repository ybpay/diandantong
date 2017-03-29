CrmModules.add_service('recharge_product_model')
angular.module('crm.services.recharge_product_model', []).
  factory('RechargeProductModel', [function(){
    return {
      build: build,
      to_params: to_params,
    }

    function build(){
      return {
        name: "",
        price: "100",
        recharge_amount: "100",
        extra_credits: "0",
        first_recharge_available_amount: "100",
        support_all_branch: true,
        branch_ids: [],
        branch_group_ids: [],
      };
    }

    function to_params(object){
      var rp = {}
      angular.forEach(["name", "price", "recharge_amount", "extra_credits", "first_recharge_available_amount", "support_all_branch"], function(key){
        rp[key] = object[key]
      })
      rp.branch_ids_string = object.branch_ids.join(",")
      rp.branch_group_ids_string = object.branch_group_ids.join(",")
      return rp
    }
  }])