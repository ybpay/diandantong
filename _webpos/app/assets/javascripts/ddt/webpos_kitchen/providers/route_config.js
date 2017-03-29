WebposModules.add('route_config')
angular.module('webpos.route_config',[]).
  provider('RouteConfig',function(){
    this.$get = function(){
      var all_configs = [];

      var base_app_template_url = "/webpos/templates_kitchen/"
      function template(url){
        return base_app_template_url + url;
      }

      var base_config = [
        {
          state: "shop",
          url: '/shop',
          abstract: true,
          templateUrl:  template('shop.html'),
          controller:   'ShopController',
          feature: 'model_shop',
        },
        {
          state: "shop.branches",
          url: '/branches',
          views:{
            "content": {
              templateUrl:  template('branches.html'),
              controller:   'BranchesController'
            }
          },
          feature: 'model_branch',
        },
        {
          state: "shop.branch",
          url: '/branch/:branch_id',
          views:{
            "content": {
              templateUrl:  template('branch.html'),
              controller:   'BranchController'
            }
          },
          feature: 'model_branch',
        },
        {
          state: "shop.branch_setting",
          url: '/branch_setting/:branch_id',
          views:{
            "content": {
              templateUrl:  template('branch_setting.html'),
              controller:   'BranchSettingController'
            }
          },
         feature: 'model_branch',
        },
        {
          state: "login",
          url: '/login',
          templateUrl:  template('login.html'),
          controller:   'LoginController',
          feature: 'model_account',
        },
      ]

      add_config(base_config);

      function get(){
        return all_configs;
      }
      function add_config(config){
        all_configs = all_configs.concat(config);
      }
      return {
        get: get
      }
    }
  });
