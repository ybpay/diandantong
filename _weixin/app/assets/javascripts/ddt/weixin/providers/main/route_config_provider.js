angular.module('ddt_app.route_config.main', []).
  provider('RouteConfig', function () {
    this.$get = function(){
        var all_configs = []

        var base_configs = [
          {
            path:         '/',
            templateUrl:  '/shops/show.html',
            controller:   'shopController',
            feature:      'model_shop'
          }
        ]

        var branch_configs = [
          {
            path:         '/branches',
            templateUrl:  '/main/branches/index.html',
            controller:   'branchesController',
            feature:      'model_branch'
          },
          {
            path:         '/delivery_branches',
            templateUrl:  '/main/branches/delivery_index.html',
            controller:   'deliveryBranchesController',
            feature:      'model_branch'
          },
          {
            path:         '/branches/:branch_id',
            templateUrl:  '/main/branches/show.html',
            controller:   'branchController',
            feature:      'model_branch'
          },
          {
            path:         '/branches/:branch_id/introduction',
            templateUrl:  '/main/branches/introduction.html',
            controller:   'branchController',
            feature:      'model_branch'
          },
          {
            path:         '/branches_search',
            templateUrl:  '/main/branches/search.html',
            controller:   'searchController',
            feature:      'model_branch'
          }
        ];

        var promotion_configs = [
          {
            path:         '/promotions',
            templateUrl:  '/main/promotions/index.html',
            controller:   'promotionsController',
            feature:      'base_event_promotion'
          },
          {
            path:         '/promotions/:promotion_id',
            templateUrl:  '/main/promotions/show.html',
            controller:   'promotionController',
            feature:      'base_event_promotion'
          }
        ];

        var search_configs = [
          {
            path:         '/search',
            templateUrl:  '/searches/index.html',
            controller:   'searchController',
            feature:      'wechat_api'
          }
        ];




        var favorite_branch_configs = [
          {
            path:         '/favorite_branches',
            templateUrl:  '/main/favorite_branches/index.html',
            controller:   'favoriteBranchesController'
          }
        ];

        var comments_configs = [
          {
            path:         '/branches/:branch_id/comments',
            templateUrl:  '/main/comments/index.html',
            controller:   'commentsController'
          }
        ];

        var article_config = [
          {
            path:         '/articles/:article_id',
            templateUrl:  '/main/articles/show.html',
            controller:   'articleController'
          }];

        add_config(base_configs);
        add_config(branch_configs);
        add_config(search_configs);
        add_config(promotion_configs);
        add_config(favorite_branch_configs);
        add_config(comments_configs);
        add_config(article_config);
        // add_config(sign_record_configs);
        // add_config(wechat_share_records_configs);
        // add_config(misc_configs);
        // add_config(exchange_code_configs);
        // add_config(recharge_products_configs);

        function get(){
          return all_configs;
        }

        function add_config(config){
          all_configs = all_configs.concat(config)
        }

        return {
            get: get
        }
    }
  })
