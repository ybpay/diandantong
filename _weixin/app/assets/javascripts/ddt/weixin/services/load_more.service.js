//
// 分页服务工厂
//
Ddt.factory('LoadMoreServiceFactory', [
  function () {

    //
    // 参数对象
    // * id: 服务ID
    // * per_page: 页长，默认为 8
    // * onLoadMore: function(page, per_page, timestamp, success) 响应加载更多旧数据
    //   - page: 当前加载页
    //   - per_page: 注册时设定的页长
    //   - timestamp: 注册时间戳，用以固定记录窗口
    //   - success: function(records) 处理成功的回调函数
    // * onNoMore: function() 无更多数据
    // * onLockMore: function() 加载更多锁定中，如果客户再尝试调用 loadMore，会触发此函数
    // * update: function(olds) 供客户更新数据
    //   - olds: 当前已加载的所有记录
    //
    // 返回对象提供:
    // loadMore: function() 加载更多旧数据
    // reload: function() 重置数据
    // update: function() 触发 handler.update
    // isLoading: function() 加载中？
    //
    var LoadMoreService = function (handler) {
      var olds, ots, nextPage, noMore, loadingMore;
      this.handler = handler;
      var This = this;

      this.reload = function () {
        olds = []; // 已加载的页，除最后一页
        ots = Date.now(); // 旧数据窗时间戳
        nextPage = 1; // 将要加载的页
        noMore = false; // 指示已经加载完成
        loadingMore = false;

        This.update();
      };

      this.update = function () {
        var hl = this.handler;
        if (hl.update) {
          hl.update(olds);
        }
      };

      this.reload();  // 初始化

      this.loadMore = function (clearOldData) {
        var hl = this.handler;
        if (loadingMore) {
          if (hl.onLockMore) {
            hl.onLockMore();
          }
        } else if (!noMore && hl.onLoadMore) {
          loadingMore = true;
          if(clearOldData){
            nextPage = 1;
          }

          var per_page = hl.per_page || 8;
          hl.onLoadMore(nextPage, per_page, ots, function (records) {
            loadingMore = false;
            if(clearOldData){
              This.reload();
            }
            if (records.length > 0) {
              olds = olds.concat(records);
              nextPage += 1;
              if(records.length < per_page){
                noMore = true;
                if (hl.onNoMore) {
                  hl.onNoMore();
                }
              }
              This.update();
            } else {
              // 要加载的页返回空数据，表示已经加载完成
              noMore = true;
              if (hl.onNoMore) {
                hl.onNoMore();
              }
            }
          });
        }
      }

      this.isLoading = function () {
        return loadingMore;
      }

    };

    var cache = {};
    return {
      //
      // 创建加载数据服务，新创建完成后，会自动加载一页。如复用以前的数据，会自动调用 update
      //
      createLoadMoreService: function (handler) {
        var service;
        if (handler.id) {
          if (cache[handler.id]) {
            service = cache[handler.id];
            service.handler = handler;
            service.update(); // 更换了 handler 需要更新下
          } else {
            service = new LoadMoreService(handler);
            cache[handler.id] = service;
            service.reload();
            service.loadMore(); // 初始加载
          }
        } else {
          serivce = new LoadMoreService(handler);
          service.reload();
          serivce.loadMore(); // 初始加载
        }
        return service;
      }
    }
  }]);
