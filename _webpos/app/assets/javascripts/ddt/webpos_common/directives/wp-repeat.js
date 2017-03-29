//==================================================================================
//
// 目前根据需要, DOM 重用模式建议使用 默认 或 fix
//
// wp-repeat
//
// examples:
//
// 1. 默认实现, 与 ng-repeat 功能相同
//   <div wp-repeat="element in collection track by element.id">
//      {{::element.name}}
//   </div>
//
//
//   <div wp-repeat-start="element in collection track by element.id">START </div>
//   <div>{{::element.name}}</div>
//   <div wp-repeat-end> END</div>
//
// 2. DOM 固定模式。一般情况下性能最佳的模式, 但与单向绑定冲突, 对大集合慎用。
//   <div wp-repeat="element in collection track by element.id"
//      dom-reuse="fix">
//      {{element.name}}
//   </div>
//
// 3. 集合元素 DOM 全量缓存模式。适用于集合元素相对位置稳定的情况。
//   <div wp-repeat="element in collection track by element.id"
//      dom-reuse="all">
//      {{::element.name}}
//   </div>
//
// 4. 静态模式, 适用于一次绑定. 然后 DOM 与 scope 不再关联。使 DOM 缓存达到最佳性能。
//    此模式下, 应使用 onclick="" 或 controller 中绑定事件处理函数。
//   <div wp-repeat="element in collection track by element.id"
//      dom-reuse="static"
//      dom-cache="myCache"
//      dom-cache-prefix="my-dom-cache-prefix">
//      {{::element.name}}
//   </div>
//
//    <!-- 使用内置缓存工厂 -->
//   <div wp-repeat="element in collection track by element.id"
//      dom-reuse="static"
//      dom-cache-factory="cacheFactory"
//      dom-cache-prefix="my-dom-cache-prefix">
//      {{::element.name}}
//   </div>
//
//    <!-- 使用 onclick 绑定事件 -->
//    <wp-btn-sm  wp-repeat="category in categories track by category.id"
//      dom-reuse="static"
//      dom-cache="categories_dom_cache"
//      dom-cache-prefix="category"
//      class="fillet category-btn category-btn-{{category.id}}"
//      onclick="$(this).data('$apply')(function($scope, $elem){$scope.change_active_category($elem.data('category'))})"
//        {{::category.name}}
//      </wp-btn-sm>
//
// -------------------------------------------------------------------------------
// dom-reuse:
//   auto: 元素移除时,也移除 DOM (default)
//      USE_SCENE: 默认实现, 同 ng-repeat
//   fix: 固定 DOM , 利用 watcher 更新内容。
//      USE_SCENE: 可利用 watcher 更新时,此为最优实现
//      CAUTION: 不可使用 one-way-binding
//      TODO: DOM 延迟绑定, 以实现利用缓存迅速显示
//   all: 为每个 trackById 创建 DOM。当且仅当元素在集合中时, 显示对应的 DOM。
//      USE_SCENE: 适用于集合元素相对位置不会改变的情况
//      CAUTION: DOM 的位置不会随元素相对位置而调整
//      TODO: 实现自动位置调整会有性能代价
//   static: 静态模式, 可使用缓存加速渲染。
//
// ---------------------------------------------------------------------------------
//
// 静态内容缓存: 当需要获取 DOM 和 scope 时,优先从缓存中加载。缓存不会被自动清理
//   CAUSION: 只适用于静态内容。
//   TODO: 缓存 DOM 的延迟重绑定
//
// dom-cache-factory:
//    local: 局部变量
//    cacheFactory: angular 缓存
// dom-cache:
//    缓存对象, 对象需要支持 get(key)/put(key,value) 方法。设置此属性后,忽略 dom-cache-factory
// dom-cache-prefix: 缓存键的前缀
// TODO: localStorage
//
//==================================================================================

(function () {

  var DOM_REUSE_MODE_ALL = "all";
  var DOM_REUSE_MODE_FIX = "fix";
  var DOM_REUSE_MODE_AUTO = "auto";
  var DOM_REUSE_MODE_STATIC = "static";

  var DOM_CACHE_FACTORY_LOCAL = "local";
  var DOM_CACHE_FACTORY_CACHE_FACTORY = "cacheFactory";
  var DOM_CACHE_FACTORY_LOCAL_STORAGE = "localStorage";

  //=====================================================================================
  // 缓存包装器
  //=====================================================================================

  function LocalDomCache(prefix) {
    var cache = {}
    this.prefix = prefix;
    this.get = function (key) {
      return cache[this.prefix + key]
    }
    this.put = function (key, value) {
      cache[this.prefix + key] = value
    }
  }

  function CacheFactoryDomCache(prefix, $cacheFactory) {
    var cache = $cacheFactory.get("wp-repeat-dom-cache");
    if (!cache) {
      cache = $cacheFactory("wp-repeat-dom-cache")
    }
    this.prefix = prefix;
    this.get = function (key) {
      return cache.get(this.prefix + key)
    }
    this.put = function (key, value) {
      cache.put(this.prefix + key, value);
    }
  }

  function LocalStorageDomCache(prefix) {
    this.prefix = prefix;
    this.get = function (key) {
      return localStorage.getItem(this.prefix + key);
    }
    this.put = function (key, value) {
      localStorage.setItem(this.prefix + key, value);
    }
  }

  function DelegateDomCache(prefix, cache) {
    this.cache = cache;
    this.prefix = prefix;
    this.get = function (key) {
      return this.cache.get(this.prefix + key)
    }
    this.put = function (key, value) {
      this.cache.put(this.prefix + key, value);
    }
  }

  //=============================================================================
  // cached version of ng-repeat
  //=============================================================================

  WebposModules.add_directive('wp_repeat')
  angular.module('webpos.directives.wp_repeat', [])
    .directive('wpRepeat', ['$parse', '$animate', '$timeout', '$cacheFactory', 'WpNgUtils',
      function ($parse, $animate, $timeout, $cacheFactory, WpNgUtils) {

        var minErr = WpNgUtils.minErr;
        var getBlockNodes = WpNgUtils.getBlockNodes;
        var hashKey = WpNgUtils.hashKey;
        var createMap = WpNgUtils.createMap;
        var isArrayLike = WpNgUtils.isArrayLike;
        var jqLite = WpNgUtils.jqLite;

        var NG_REMOVED = '$$NG_REMOVED';
        var wpRepeatMinErr = minErr('wpRepeat');

        var updateScope = function (scope, index, valueIdentifier, value, keyIdentifier, key, arrayLength) {
          // TODO(perf): generate setters to shave off ~40ms or 1-1.5%
          scope[valueIdentifier] = value;
          if (keyIdentifier) scope[keyIdentifier] = key;
          scope.$index = index;
          scope.$first = (index === 0);
          scope.$last = (index === (arrayLength - 1));
          scope.$middle = !(scope.$first || scope.$last);
          // jshint bitwise: false
          scope.$odd = !(scope.$even = (index & 1) === 0);
          // jshint bitwise: true
        };

        var getBlockStart = function (block) {
          return block.clone[0];
        };

        var getBlockEnd = function (block) {
          return block.clone[block.clone.length - 1];
        };

        var tryGetFromDomCache = function (domCache, blockId) {
          var reusableBlock
          if (domCache) {
            reusableBlock = domCache.get(blockId)
            if (reusableBlock) {
              reusableBlock.fromDomCache = true
            }
          }
          return reusableBlock
        }

        return {
          restrict: 'A',
          multiElement: true,
          transclude: 'element',
          priority: 1000,
          terminal: true,
          $$tlb: true,
          compile: function wpRepeatCompile($element, $attr) {
            var expression = $attr.wpRepeat;

            // DOM 重用模式
            var domReuseMode = $attr.domReuse || DOM_REUSE_MODE_AUTO
            var domReuseAll = domReuseMode == DOM_REUSE_MODE_ALL
            var domReuseFix = domReuseMode == DOM_REUSE_MODE_FIX
            var domReuseAuto = domReuseMode == DOM_REUSE_MODE_AUTO
            var domReuseStatic = domReuseMode == DOM_REUSE_MODE_STATIC

            // DOM 缓存模式
            var domCache;
            var domCachePrefix = $attr.domCachePrefix

            if (!domReuseStatic && ($attr.domCache || $attr.domCacheFactory)){
              throw wpRepeatMinErr('idr', "Only static dom reuse mode supports cache")
            }

            var domCacheGetter;
            var domCacheExpr = $attr.domCache;
            if (domCacheExpr) {
              domCacheGetter = $parse(domCacheExpr)
            } else {
              var domCacheFactory = $attr.domCacheFactory
              if (domCacheFactory) {
                switch (domCacheFactory) {
                  case DOM_CACHE_FACTORY_LOCAL:
                    domCache = new LocalDomCache(domCachePrefix);
                    break;
                  case DOM_CACHE_FACTORY_LOCAL_STORAGE:
                    domCache = new LocalStorageDomCache(domCachePrefix);
                    break;
                  case DOM_CACHE_FACTORY_CACHE_FACTORY:
                    domCache = new CacheFactoryDomCache(domCachePrefix, $cacheFactory)
                    break;
                }
              }
            }

            var ngRepeatEndComment = document.createComment(' end wpRepeat: ' + expression + ' ');

            var match = expression.match(/^\s*([\s\S]+?)\s+in\s+([\s\S]+?)(?:\s+as\s+([\s\S]+?))?(?:\s+track\s+by\s+([\s\S]+?))?\s*$/);

            if (!match) {
              throw wpRepeatMinErr('iexp', "Expected expression in form of '_item_ in _collection_[ track by _id_]' but got '{0}'.",
                expression);
            }

            var lhs = match[1];
            var rhs = match[2];
            var rhsGetter = domReuseStatic ? $parse(rhs) : null;
            var aliasAs = match[3];
            var trackByExp = match[4];

            match = lhs.match(/^(?:(\s*[\$\w]+)|\(\s*([\$\w]+)\s*,\s*([\$\w]+)\s*\))$/);

            if (!match) {
              throw wpRepeatMinErr('iidexp', "'_item_' in '_item_ in _collection_' should be an identifier or '(_key_, _value_)' expression, but got '{0}'.",
                lhs);
            }
            var valueIdentifier = match[3] || match[1];
            var keyIdentifier = match[2];

            if (aliasAs && (!/^[$a-zA-Z_][$a-zA-Z0-9_]*$/.test(aliasAs) ||
              /^(null|undefined|this|\$index|\$first|\$middle|\$last|\$even|\$odd|\$parent|\$root|\$id)$/.test(aliasAs))) {
              throw wpRepeatMinErr('badident', "alias '{0}' is invalid --- must be a valid JS identifier which is not a reserved name.",
                aliasAs);
            }

            var trackByExpGetter, trackByIdExpFn, trackByIdArrayFn, trackByIdObjFn;
            var hashFnLocals = {$id: hashKey};

            if (trackByExp) {
              trackByExpGetter = $parse(trackByExp);
            } else {
              trackByIdArrayFn = function (key, value) {
                return hashKey(value);
              };
              trackByIdObjFn = function (key) {
                return key;
              };
            }

            return function wpRepeatLink($scope, $element, $attr, ctrl, $transclude) {

              if (trackByExpGetter) {
                trackByIdExpFn = function (key, value, index) {
                  // assign key, value, and $index to the locals so that they can be used in hash functions
                  if (keyIdentifier) hashFnLocals[keyIdentifier] = key;
                  hashFnLocals[valueIdentifier] = value;
                  hashFnLocals.$index = index;
                  return trackByExpGetter($scope, hashFnLocals);
                };
              }

              // domReuseModeAll: 可复用块
              var cacheBlockMap = createMap()
              // domReuseModeFix:  可复用块
              var reusableBlocks = []

              if (domCacheGetter) {
                domCache = domCacheGetter($scope)
              }

              // Store a list of elements from previous run. This is a hash where key is the item from the
              // iterator, and the value is objects with following properties.
              //   - scope: bound scope
              //   - element: previous element.
              //   - index: position
              //
              // We are using no-proto object so that we don't need to guard against inherited props via
              // hasOwnProperty.
              var lastBlockMap = createMap();

              //watch props
              $scope.$watchCollection(rhs, function wpRepeatAction(collection) {
                  var index, length,
                    previousNode = $element[0],     // node that cloned nodes should be inserted after
                                                    // initialized to the comment node anchor
                    nextNode,
                  // Same as lastBlockMap but it has the current state. It will become the
                  // lastBlockMap on the next iteration.
                    nextBlockMap = createMap(),
                    collectionLength,
                    key, value, // key/value of iteration
                    trackById,
                    trackByIdFn,
                    collectionKeys,
                    block,       // last object information {scope, element, id}
                    nextBlockOrder,
                    elementsToRemove;

                  if (aliasAs) {
                    $scope[aliasAs] = collection;
                  }

                  if (isArrayLike(collection)) {
                    collectionKeys = collection;
                    trackByIdFn = trackByIdExpFn || trackByIdArrayFn;
                  } else {
                    trackByIdFn = trackByIdExpFn || trackByIdObjFn;
                    // if object, extract keys, sort them and use to determine order of iteration over obj props
                    collectionKeys = [];
                    for (var itemKey in collection) {
                      if (collection.hasOwnProperty(itemKey) && itemKey.charAt(0) != '$') {
                        collectionKeys.push(itemKey);
                      }
                    }
                    collectionKeys.sort();
                  }

                  collectionLength = collectionKeys.length;
                  nextBlockOrder = new Array(collectionLength);

                  // locate existing items
                  for (index = 0; index < collectionLength; index++) {
                    key = (collection === collectionKeys) ? index : collectionKeys[index];
                    value = collection[key];
                    trackById = trackByIdFn(key, value, index);

                    // how to reuse last/cached block?
                    var reusableBlock;

                    // 优先从上次缓存中获取
                    switch (domReuseMode) {
                      case DOM_REUSE_MODE_AUTO:
                      {
                        reusableBlock = lastBlockMap[trackById]
                        if (!reusableBlock) {
                          reusableBlock = tryGetFromDomCache(domCache, trackById)
                        }
                        break;
                      }
                      case DOM_REUSE_MODE_FIX:
                      {
                        // 仅新增块利用到缓存
                        break;
                      }
                      case DOM_REUSE_MODE_ALL:
                      {
                        reusableBlock = cacheBlockMap[trackById]
                        if (!reusableBlock) {
                          reusableBlock = tryGetFromDomCache(domCache, trackById)
                        }
                        break;
                      }
                      case DOM_REUSE_MODE_STATIC: {
                        reusableBlock = tryGetFromDomCache(domCache, trackById)
                      }
                    }

                    if (reusableBlock) {
                      // 发现缓存过的对象
                      block = reusableBlock;
                      delete lastBlockMap[trackById];
                      nextBlockMap[trackById] = block;
                      nextBlockOrder[index] = block;
                    } else if (nextBlockMap[trackById]) {
                      // if collision detected. restore lastBlockMap and throw an error
                      angular.forEach(nextBlockOrder, function (block) {
                        if (block && block.scope) lastBlockMap[block.id] = block;
                      });
                      throw wpRepeatMinErr('dupes',
                        "Duplicates in a repeater are not allowed. Use 'track by' expression to specify unique keys. Repeater: {0}, Duplicate key: {1}, Duplicate value: {2}",
                        expression, trackById, value);
                    } else {
                      // new never before seen block
                      nextBlockOrder[index] = {id: trackById, scope: undefined, clone: undefined};
                      nextBlockMap[trackById] = true;
                    }
                  }

                  // remove leftover items
                  if (!domReuseFix) { // for domReuseFix, assume all item are new
                    for (var blockKey in lastBlockMap) {
                      block = lastBlockMap[blockKey];
                      elementsToRemove = getBlockNodes(block.clone);
                      switch (domReuseMode) {
                        case DOM_REUSE_MODE_ALL:
                        {
                          elementsToRemove.hide();
                          break;
                        }
                        case DOM_REUSE_MODE_STATIC:
                        case DOM_REUSE_MODE_AUTO:
                        {
                          $animate.leave(elementsToRemove);
                          if (elementsToRemove[0].parentNode) {
                            // if the element was not removed yet because of pending animation, mark it as deleted
                            // so that we can ignore it later
                            for (index = 0, length = elementsToRemove.length; index < length; index++) {
                              elementsToRemove[index][NG_REMOVED] = true;
                            }
                          }

                          // when dom-reuse-static , a block may not have a scope
                          if (block.scope) {
                            block.scope.$destroy();
                          }
                          break;
                        }
                      }
                    }
                  }

                  // we are not using forEach for perf reasons (trying to avoid #call)
                  for (index = 0; index < collectionLength; index++) {
                    key = (collection === collectionKeys) ? index : collectionKeys[index];
                    value = collection[key];
                    block = nextBlockOrder[index];

                    /**
                     * call when come with new item which we don't know about
                     */
                    function callWpRepeatTransclude() {
                      // TODO: 切换页面的主要性能瓶颈, 以后的优化方向: 延迟链接/需要使用时再链接。
                      $transclude(function wpRepeatTransclude(clone, scope) {
                        block.scope = scope;
                        // http://jsperf.com/clone-vs-createcomment
                        var endNode = ngRepeatEndComment.cloneNode(false);
                        clone[clone.length++] = endNode;

                        // TODO(perf): support naked previousNode in `enter` to avoid creation of jqLite wrapper?
                        $animate.enter(clone, null, jqLite(previousNode));
                        previousNode = endNode;
                        // Note: We only need the first/last node of the cloned nodes.
                        // However, we need to keep the reference to the jqlite wrapper as it might be changed later
                        // by a directive with templateUrl when its template arrives.
                        block.clone = clone;
                        nextBlockMap[block.id] = block;
                        updateScope(block.scope, index, valueIdentifier, value, keyIdentifier, key, collectionLength);
                        if (domCache) {
                          domCache.put(block.id, block)
                        }
                      })
                    }

                    switch (domReuseMode) {
                      case DOM_REUSE_MODE_ALL:
                      {
                        if (block.scope) {
                          if (block.fromDomCache) {
                            $animate.enter(block.clone, null, jqLite(previousNode));
                            block.fromDomCache = false
                            // TODO: delay bind scope to dom
                            // jQuery.cache[$element[jQuery.expando]].data.$scope
                            // $element.data('$scope')
                          }
                          // 更新最后结点位置
                          previousNode = getBlockEnd(block);

                          // 如果 fromDomCache, 因没有 watcher 和 listenr, scope 的改变不会反映到 DOM
                          updateScope(block.scope, index, valueIdentifier, value, keyIdentifier, key, collectionLength);
                          getBlockNodes(block.clone).show()
                        } else {
                          callWpRepeatTransclude();
                          cacheBlockMap[block.id]
                        }
                        break;
                      }

                      case DOM_REUSE_MODE_AUTO:
                      {
                        if (block.scope) {
                          // if we have already seen this object, then we need to reuse the
                          // associated scope/element

                          if (block.fromDomCache) {
                            $animate.enter(block.clone, null, jqLite(previousNode));
                            block.fromDomCache = false
                            // TODO: delay bind scope to dom
                          } else {
                            nextNode = previousNode;

                            // skip nodes that are already pending removal via leave animation
                            do {
                              nextNode = nextNode.nextSibling;
                            } while (nextNode && nextNode[NG_REMOVED]);

                            if (getBlockStart(block) != nextNode) {
                              // existing item which got moved
                              $animate.move(getBlockNodes(block.clone), null, jqLite(previousNode));
                            }
                          }
                          previousNode = getBlockEnd(block);
                          updateScope(block.scope, index, valueIdentifier, value, keyIdentifier, key, collectionLength);
                        } else {
                          callWpRepeatTransclude()
                        }
                        break;
                      }

                      case DOM_REUSE_MODE_STATIC:
                      {
                        if (block.clone) {
                          // we fetch it from cache
                          $animate.enter(block.clone, null, jqLite(previousNode));
                          block.clone.data('$scope', $scope)
                          block.clone.data(valueIdentifier, value)
                          block.clone.data('$apply', (function(tElem, tScope){
                            return function wpRepeatApply(applyFn){
                              if (applyFn){
                                tScope.$apply(function(){
                                  applyFn(tScope, tElem)
                                })
                              }
                            };
                          })(block.clone, $scope));
                        } else {
                          $transclude(function(clone, scope){
                            var endNode = ngRepeatEndComment.cloneNode(false);
                            clone[clone.length++] = endNode;
                            $animate.enter(clone, null, jqLite(previousNode));
                            block.clone = clone;
                            block.scope = scope;
                            nextBlockMap[block.id] = block;
                            updateScope(block.scope, index, valueIdentifier, value, keyIdentifier, key, collectionLength);
                            block.clone.data(valueIdentifier, value)
                            block.clone.data('$apply', function wpRepeatApplyLocal(applyFn){
                              if (applyFn){
                                scope.$apply(function(){
                                  applyFn(scope, clone)
                                })
                              }
                            });

                            if (domCache) {
                              domCache.put(block.id, block)
                            }
                          });
                        }
                        previousNode = getBlockEnd(block);
                        break;
                      }

                      case DOM_REUSE_MODE_FIX:
                      {
                        // 获取可复用的结点
                        // 如果找到
                        //    应用 DOM 到新的 scope
                        //    从可复用列表中移除
                        //    更新 previous node
                        // 如果找不到
                        //    使用之前的方法创建
                        //    添加到可复用块
                        //

                        var reusableBlock = reusableBlocks[index]
                        if (reusableBlock) {
                          block.clone = reusableBlock.clone
                          block.scope = reusableBlock.scope

                          // 更新最后结点位置
                          previousNode = getBlockEnd(block);

                          // 更新索引和缓存
                          nextBlockMap[block.id] = block;
                          updateScope(block.scope, index, valueIdentifier, value, keyIdentifier, key, collectionLength);
                          getBlockNodes(block.clone).show();
                        } else {
                          // no more reusable block, try to fetch from cache
                          reusableBlock = tryGetFromDomCache(domCache, block.id)
                          if (reusableBlock) {
                            block.clone = reusableBlock.clone;
                            block.scope = reusableBlock.scope;

                            $animate.enter(block.clone, null, jqLite(previousNode));
                            previousNode = getBlockEnd(block);
                            nextBlockMap[block.id] = block;
                            updateScope(block.scope, index, valueIdentifier, value, keyIdentifier, key, collectionLength);
                            getBlockNodes(block.clone).show()

                            // TODO: delay bind scope to dom
                            //$timeout(function(block){
                            //  return function wpRepeatRefreshDomCacheNode(){
                            //    $transclude(function wpRepeatTranscludeOnMouseover(clone, scope) {
                            //      console.info("wpRepeatTranscludeOnMouseover on " + valueIdentifier + ": ", block.scope[valueIdentifier])
                            //      var previousNode = getBlockEnd(block)
                            //      // http://jsperf.com/clone-vs-createcomment
                            //      var endNode = ngRepeatEndComment.cloneNode(false);
                            //      clone[clone.length++] = endNode;
                            //
                            //      //$animate.enter(clone, null, jqLite(previousNode));
                            //      angular.element(previousNode).after(clone)
                            //      //$animate.leave(block.clone);
                            //      block.clone.detach()
                            //      block.clone = clone;
                            //      // TODO: destroy scope somewhere
                            //
                            //      // copy scope
                            //      scope[valueIdentifier] = block.scope[valueIdentifier];
                            //      if (keyIdentifier) scope[keyIdentifier] = block.scope[keyIdentifier];
                            //      scope.$index = block.scope.$index;
                            //      scope.$first = block.scope.$first;
                            //      scope.$last = block.scope.$last;
                            //      scope.$middle = block.scope.$middle;
                            //      // jshint bitwise: false
                            //      scope.$odd = block.scope.$odd
                            //      // jshint bitwise: true
                            //
                            //      block.scope = scope;
                            //
                            //      nextBlockMap[block.id] = block;
                            //    })
                            //  }
                            //}(block), 0);

                          } else {
                            callWpRepeatTransclude();
                          }
                          reusableBlocks.push(block)
                        }
                        break;
                      }
                    }
                  }

                  if (domReuseFix) {
                    // hide all extra blocks
                    for (; index < reusableBlocks.length; ++index) {
                      getBlockNodes(reusableBlocks[index].clone).hide()
                    }
                  }

                  lastBlockMap = nextBlockMap;
                });
            };
          }
        };
      }]);

}());
