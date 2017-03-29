Ddt.module('ddt_app.directives.filterNav', [])
    .directive('filterNavTabs', ['$rootScope', function ($rootScope) {
        return {
            templateUrl: $rootScope.directive_partial('filter-nav/filter-nav-tabs'),
            replace: true,
            restrict: 'E',
            transclude: true,
            scope: {
                onPickup: '=onPickup'
            },
            controller: ['$element', '$scope', function ($element, $scope) {
                var panes = $scope.panes = [];

                this.addPane = function (pane) {
                    panes.push(pane);
                };

                this.pickup = function(filter){
                    $scope.select();
                    $scope.onPickup.apply($element, [filter, $.map(panes, function(pane){
                        return pane.pickupFilter;
                    })]);
                }

                // 展开/收起 过滤菜单
                $scope.toggle = function(pane) {
                    if (pane.selected == false){
                        $scope.select(pane);
                    }else{
                        pane.selected = false;
                        $scope.mask = false;
                    }
                }

                // 选择过滤菜单
                $scope.select = function (pane) {
                    $.each(panes, function(i,p) {
                        p.selected = false;
                    });
                    if (pane) {
                        pane.selected = true;
                        $scope.mask = true;
                    }else{
                        $scope.mask = false;
                    }
                };
            }]
        };
    }])

    .directive('filterNavPane', ['$rootScope', function($rootScope){
        return {
            require: '^filterNavTabs',
            templateUrl: $rootScope.directive_partial('filter-nav/filter-nav-pane'),
            replace: true,
            restrict: 'E',
            scope: {
                top: '=filter'
            },
            controller: ['$element', '$scope', function($element, $scope){
//                console.info('filterNavPane controller', $scope.top);

                // 选择子菜单
                this.selectItem = function(item){
                    this.mark(item);
                    $scope.sub = item;
                    $scope.current = item.parent;
                    $scope.parent = $scope.current.parent;
                }

                // 标注子菜单
                // 设置 item 子结点的 parent 引用
                this.mark = $scope.mark = function(item){
                    var subHasSub = false;
                    if (item && !item.marked) {
                        item.marked = true;
                        // 记录反向引用
                        var subs = item.collection;
                        if (subs && subs.length > 0) {
                            item.hasSub = true;
                            $.each(subs, function (i, sub) {
                                sub.parent = item;
                                var subsubs = sub.collection;
                                if (subsubs && subsubs.length > 0){
                                    sub.hasSub = true;
                                    subHasSub = true;
                                }
                            });
                        }
                    }
                    return subHasSub;
                }

                // 选择过滤器
                this.pickup = function(filter){
                    $scope.pickupFilter = filter;
                    $scope.tabsCtrl.pickup(filter);
                }
            }],

            link: function(scope, element, attrs, tabsCtrl){
//                console.info('filterNavPane link', scope.top);
                scope.tabsCtrl = tabsCtrl;
                tabsCtrl.addPane(scope);
                scope.multiLevel = scope.mark(scope.top);
                // 处于中间的过滤器和顶端过滤器都置于此
                scope.current = scope.top;
                scope.pickupFilter = scope.top;
            }
        }
    }])

    .directive('filterNavSubPane', ['$rootScope', 'QueryService', function($rootScope, QueryService){
        return {
            require: '^filterNavPane',
            templateUrl: $rootScope.directive_partial('filter-nav/filter-nav-sub-pane'),
            replace: true,
            restrict: 'E',
            scope: {
                pickupFilter: '=',
                filter: '=filter'   // 当前结点
            },
            link: function(scope, element, attrs, paneCtrl){
//                console.info('filterNavSubPane', scope.filter);
                scope.selectItem = function(item){
                    paneCtrl.selectItem(item);
                }

                scope.pickup = function(filter){
                    paneCtrl.pickup(filter);
                }

                // 初始化 filter
                var initialQuery = QueryService.getCombineQuery();
                if (scope.filter) {
                  var subs = scope.filter.collection;
                  if (subs) {
                    angular.forEach(subs.concat(scope.filter), function (sub) {
                      if (initialQuery[sub.op] == sub.value) {
                        scope.pickup(sub);
                      }
                    });
                  }
                }
            }
        }
    }])

;
