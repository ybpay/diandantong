"use strict"

Ddt.module("ddt_app.controllers.comment", [])
.controller('commentsController', [
  '$rootScope', '$scope', '$routeParams', 'CommentService', 'BranchService',
  function($rootScope, $scope, $routeParams, CommentService, BranchService){

    BranchService.get({id: $routeParams.branch_id}, function(branch){
      $rootScope.title = branch.name;
    });

    CommentService.query($routeParams.branch_id, function(comments){
      $scope.comments = comments;
    });
}]);
