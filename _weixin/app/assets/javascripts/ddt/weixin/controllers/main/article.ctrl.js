"use strict"

Ddt.controller('articleController', [
  '$rootScope', '$scope', '$routeParams','ArticleService',
  function($rootScope, $scope, $routeParams, ArticleService){
    ArticleService.get($routeParams.article_id, function(article){
      $scope.article = article
    });

    $rootScope.shareRecordTrigger = {
      triggerBeforeCreateRecord: function(resp, wxShareConfig){
        wxShareConfig.title = $scope.article.title;
        wxShareConfig.desc = $scope.article.introduction;
        wxShareConfig.imgUrl = $scope.article.image;
      }
    };

  }]);