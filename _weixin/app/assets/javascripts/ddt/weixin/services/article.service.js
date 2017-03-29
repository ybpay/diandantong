Ddt.
  factory('ArticleService', ['$rootScope' , '$resource', 'DdtConst',
    function ($rootScope, $resource, DdtConst) {

    // /weixin/shops/:shop_id/articles/:id
    var Article = $resource(DdtConst.baseUrl + '/articles/:article_id', {format: 'json'}, {
      query: {method: 'GET', isArray: true, cache: true},
      get: {method: 'GET', cache: true}
    })

    function get(article_id, success){
      Article.get({article_id: article_id}, success)
    }

    return {
      get: get
    }
  }]);