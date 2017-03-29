Ddt.factory('QueryService', [ '$location', function($location){
  // 以 _ng_query_ 开头的，都是查询的参数前缀
  var QUERY_PREFIX = '_ng_query';
  var query = {}

  function buildQuery(query, url){
    UrlParser.each_parameter(function(key, value){
      var idx = key.indexOf(QUERY_PREFIX);
      if (idx == 0){
        var qkey = key.substring('_ng_'.length);
        query[qkey] = value;
      }
    }, url);
    return query;
  }

  buildQuery(query);

  return {

    getQuery: function(){
      return angular.extend({}, query);
    },

    getNgQuery: function(){
      return buildQuery({}, $location.url());
    },

    getCombineQuery: function(){
      return angular.extend(this.getQuery(), this.getNgQuery());
    },

    buildQueryString: function(query){
      return $.map(query, function(value, key){
        return '_ng_' + encodeURIComponent(key) + '=' + encodeURIComponent(value);
      }).join('&');
    }
  }
}]);
