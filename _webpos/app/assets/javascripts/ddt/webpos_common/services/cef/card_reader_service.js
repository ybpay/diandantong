WebposModules.add_service('card_reader')
angular.module('webpos.services.card_reader', []).
  factory('CardReaderService', ['$rootScope', '$resource', '$q', 'WebposObjectAsyncAdapter', function($rootScope, $resource, $q, WebposObjectAsyncAdapter){
    var sector_num = 2  //区号
    var block_num = 8   //块号
    // key_type 0为装载密码A 4为装载密码B
    var global_key_type = 0
    var global_key = "DDDDDDDDDDDD" // 全局密码
    var shop_key_type = 4
    var init_key = "FFFFFFFFFFFF" // 出厂密码

    // 内嵌浏览器中的注册的C#对象
    //var card_reader = window.CardReaderObject;
    var card_reader = WebposObjectAsyncAdapter.create({
      obtain_service: function(){
        return window.CardReaderObject;
      }
    });

    function connect_card(){
      var deferred = $q.defer()
      if (card_reader.has_object()){
        card_reader.connect().then(function(connected){
          if (connected) {
            deferred.resolve(connected)
          }else{
            $rootScope.alert("读卡器连接失败, 请检查是否已经安装读卡器.", 10000)
            deferred.reject()
          }
        })
      }else{
        $rootScope.alert("请下载安装收银系统. <a href='http://www.diandantong.com/domains/ddt/pages/download' target='_blank' style='cursor:pointer;'>下载地址</a>", 10000)
        deferred.reject()
      }
      return deferred.promise
    }

    // 寻卡
    //function find_card(){
    //  if(card_reader !== undefined){
    //    if(card_reader.connect()){
    //      return card_reader.find_card() //返回卡号
    //    }else{
    //      $rootScope.alert("读卡器连接失败, 请检查是否已经安装读卡器.", 10000)
    //      return false
    //    }
    //  }else{
    //    $rootScope.alert("请下载安装收银系统. <a href='http://www.diandantong.com/domains/ddt/pages/download' target='_blank' style='cursor:pointer;'>下载地址</a>", 10000)
    //    return false
    //  }
    //}

    function find_card(){
      return $q(function(resolve, reject){
        connect_card().then(function(){
          return card_reader.find_card().then(function(card_num){
            if (card_num) {
              resolve(card_num)
            }else{
              reject()
            }
          })
        }).catch(function(err){
          reject(err)
        })
      });
    }

    // 卡片密码初始化
    //function init_card(shop_card_key){
    //  if(find_card()){
    //    if(card_reader.authentication(sector_num, shop_key_type, init_key)){
    //      var resp = card_reader.init_key(sector_num, global_key, shop_card_key)
    //      card_reader.disconnect()
    //      return resp
    //    }else{
    //      card_reader.disconnect()
    //      find_card()
    //      if(card_reader.authentication(sector_num, shop_key_type, shop_card_key)){
    //        $rootScope.alert("该卡片已被初始化")
    //      }else{
    //        $rootScope.alert("该卡片已被其他点账户绑定")
    //      }
    //      card_reader.disconnect()
    //      return false
    //    }
    //  }
    //}

    function check_card_status(card_key){
      return $q(function(resolve, reject){
        card_reader.disconnect().then(function(){
          return find_card().then(function(card_num){
            return card_reader.authentication(sector_num, shop_key_type, card_key).then(function(auth){
              if (auth){
                if (card_key != init_key) {
                  $rootScope.alert("该卡片已被初始化")
                } else {
                  $rootScope.alert("该卡片尚未初始化")
                }
              }else{
                $rootScope.alert("该卡片已被其他点账户绑定")
              }
              return card_reader.disconnect()
            });
          });
        }).then(function(){
          reject()
        }).catch(function(){
          reject()
        })
      });
    }

    function access_card(shop_card_key, check_card_key){
      if (check_card_key == undefined){
        check_card_key = shop_card_key
      }
      var args = Array.prototype.slice.call(arguments)
      return find_card().then(function(card_num){
        return card_reader.authentication(sector_num, shop_key_type, shop_card_key).then(function(auth){
          if (auth){
            return auth
          }else{
            return check_card_status(check_card_key)
          }
        })
      });
    }


    function init_card(shop_card_key){
      return access_card(init_key).then(function(){
        return card_reader.init_key(sector_num, global_key, shop_card_key)
      })
    }

    //// 卡片密码逆初始化
    //function clear_card(){
    //  if(find_card()){
    //    var resp = card_reader.clear_key(sector_num, global_key)
    //    card_reader.disconnect()
    //    return resp
    //  }
    //}

    // 卡片密码逆初始化
    function clear_card(){
      return $q(function(resolve, reject){
        find_card().then(function(card_num){
          return card_reader.clear_key(sector_num, global_key)
        }).then(function(resp){
          card_reader.disconnect().then(function(){
            resolve(resp)
          }).catch(function(){
            resolve(resp)
          });
        }).catch(function(err){
          reject(err)
        })
      });
    }

    //// 写卡
    //function write(shop_card_key, data){
    //  if(find_card()){
    //    if(card_reader.authentication(sector_num, shop_key_type, shop_card_key)){
    //      var resp = card_reader.write(sector_num, block_num, shop_key_type, shop_card_key, data)
    //      card_reader.disconnect()
    //      return resp
    //    }else{
    //      card_reader.disconnect()
    //      find_card()
    //      if(card_reader.authentication(sector_num, shop_key_type, init_key)){
    //        $rootScope.alert("该卡片尚未初始化")
    //      }else{
    //        $rootScope.alert("该卡片已被其他点账户绑定")
    //      }
    //      card_reader.disconnect()
    //      return false
    //    }
    //  }
    //}

  function write(shop_card_key, data){
    return $q(function(resolve, reject){
      access_card(shop_card_key, init_key).then(function(){
        return card_reader.write(sector_num, block_num, shop_key_type, shop_card_key, data)
      }).then(function(resp){
        card_reader.disconnect().then(function(){
          resolve(resp)
        }).catch(function(){
          resolve(resp)
        })
      }).catch(function(err){
        reject(err)
      })
    });
  }

    //// 读卡
    //function read(shop_card_key){
    //  if(find_card()){
    //    if(card_reader.authentication(sector_num, shop_key_type, shop_card_key)){
    //      var resp = card_reader.read(sector_num, block_num, shop_key_type, shop_card_key)
    //      card_reader.disconnect()
    //      return resp
    //    }else{
    //    }
    //  }
    //}

  function read(shop_card_key){
    return $q(function(resolve, reject){
      access_card(shop_card_key, init_key).then(function(){
        return card_reader.read(sector_num, block_num, shop_key_type, shop_card_key)
      }).then(function(resp){
        card_reader.disconnect().then(function(){
          resolve(resp)
        }).catch(function(){
          resolve(resp)
        })
      }).catch(function(err){
        reject(err)
      })
    });
  }

    return {
      find_card: find_card,
      init_card: init_card,
      clear_card: clear_card,
      write: write,
      read: read
    }
  }])