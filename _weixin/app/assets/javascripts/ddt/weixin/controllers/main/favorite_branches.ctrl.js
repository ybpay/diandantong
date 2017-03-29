"use strict"

Ddt.controller('favoriteBranchesController', [
  '$rootScope', '$scope', '$compile', '$location', 'FavoriteBranchService', 'UserService', 'BranchService',
  function($rootScope, $scope, $compile, $location, FavoriteBranchService, UserService, BranchService){
    $rootScope.title = '我的收藏';

    UserService.get(function(user){
      $scope.user = user;
    });

    FavoriteBranchService.query(function(branches) {
      $scope.branches = branches;
    });

  }
]);



