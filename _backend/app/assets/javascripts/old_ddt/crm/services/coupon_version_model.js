CrmModules.add_service('coupon_version_model')
angular.module('crm.services.coupon_version_model', []).
  factory('CouponVersionModel', [function(){
    return {
      build: build,
      to_params: to_params,
    }

    function build(){
      return {
        name: "",
        coupon_type: "amount_match",
        coupon_min_usable_amount: "",
        norminal_value: "",
        product_sku: "",
        expired_type: "fixed_expired_time",
        usable_starts_at: new Date(),
        usable_expires_at: new Date(),
        usable_days_after_send: 10,
        description: "",
        max_grant_limit: "1000000",
        max_count_each_user: "",
        can_exchange: false,
        credit_count: 10000,
        appliable_to_any_branch: "",
        support_eat_in_hall: true,
        support_delivery: true,
        coupon_appliable_branch_scope_policy: "appliable_to_any_branch",
        branch_ids: [],
        coupon_usage_instructions: [],
        coupon_photos: []
      };
    }

    function to_params(object){
      var cv = {}
      cv.name                                 = object.name
      cv.coupon_type                          = object.coupon_type
      cv.coupon_min_usable_amount             = object.coupon_min_usable_amount
      cv.norminal_value                       = object.norminal_value
      cv.product_sku                          = object.product_sku
      cv.expired_type                         = object.expired_type
      cv.usable_starts_at                     = object.usable_starts_at
      cv.usable_expires_at                    = object.usable_expires_at
      cv.usable_days_after_send               = object.usable_days_after_send
      cv.description                          = object.description
      cv.max_grant_limit                      = object.max_grant_limit
      cv.max_count_each_user                  = object.max_count_each_user
      cv.can_exchange                         = object.can_exchange
      cv.credit_count                         = object.credit_count
      cv.appliable_to_any_branch              = object.appliable_to_any_branch
      cv.support_eat_in_hall                  = object.support_eat_in_hall
      cv.support_delivery                     = object.support_delivery
      cv.coupon_appliable_branch_scope_policy = object.coupon_appliable_branch_scope_policy
      cv.branch_ids_string = object.branch_ids.join(",")
      cv.coupon_usage_instructions_attributes = {}
      var tid = new Date().getTime()
      angular.forEach(object.coupon_usage_instructions, function(inst){
        if(inst.id){
          cv.coupon_usage_instructions_attributes[inst.id] = { id: inst.id, content: inst.content, _destroy: inst._destroy }
        }else{
          tid++
          cv.coupon_usage_instructions_attributes[tid] = { content: inst.content, _destroy: inst._destroy }
        }
      })
      return cv
    }
  }])