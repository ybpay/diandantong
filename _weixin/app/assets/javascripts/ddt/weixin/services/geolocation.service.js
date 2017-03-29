Ddt
  .factory('GeolocationService', ['$rootScope', '$timeout', '$interval', '$resource', '$http', 'DdtConst', 'ShopService',
  function ($rootScope, $timeout, $interval, $resource, $http, DdtConst, ShopService) {

    //
    // 染色日志备忘：在 URL 参数提供验证和启动命令后，打印定位调试日志（如果是客户端日志，需要上传到服务器端）
    // 用以快速定位特殊条件下的错误
    //
    var debug = false;
    var alertDebug = true;
    var log = function (msg, object) {
      if (debug) {
        msg = "[GeolocationService] " + msg;
        if (typeof object != 'undefined') {
          console.info(msg, object);
          if (alertDebug) {
            alert(msg + JSON.stringify(object));
          }
        } else {
          console.info(msg);
          if (alertDebug) {
            alert(msg);
          }
        }
      }
    }


    //
    // 回调函数列表。因为获取用户位置不是即时的。当客户程序请求用户位置时，
    // 可注册回调函数，当用户位置可用时，依次提供给这些回调函数。
    //
    var callbacks = []; // 当最近一次获取位置，自动执行并删除的动作

    //
    // 上一次计算出来的用户位置。
    // 最初的设置是兼容百度地图的，转换为 Google 地图后，需要把结果转换为这种形式
    // 属性为：
    // gps: { // 仅作备份，微信返回的是 gps 坐标
    //   lng: 经度
    //   lat: 纬度
    // }
    // point: { // 转换为对应地图坐标
    //   lng: 经度
    //   lat: 纬度
    // }
    // address:{
    //   formatted_address: 格式化地址 (百度地图需要生成)
    //   country: 国家 (仅GMap)
    //   province: 省份
    //   city: 城市
    //   district: 区
    //   street: 街道
    //   street_number: 号码（仅GMap)
    // }
    //
    //
    var position;
    var positionReady = false;

    //
    // 地图管理器类。供回调函数判断地图属性以决定自己的行为
    //
    var mgr = null;

    //
    // 当不支持地址信息时，默认的城市名
    //
    var DEFAULT_CITY_NAME = 'unknown';

    var MapManager = {

      // 是否初始化完成
      isInitialized: function () {
        return false;
      },
      // 初始化守护进程
      initDaemon: null,
      // 守护进程运行间隔
      daemonInterval: 10000,

      // 默认情况下，地图不支持地址信息
      supportAddress: false,

      //
      // 地图名字
      //
      name: null,

      //
      // 初始化用户位置。
      // 如果不在微信环境，用浏览器自带的用作测试
      //
      initCurrentPosition: function () {
        var This = this;
        if (WeixinApi.openInWeixin()) {
          log('initCurrentPosition by Weixin')
          wx.ready(function () {
            wx.getLocation({
              success: function (data) {
                log("getLocation", data);
                var latitude = data.latitude; // 纬度，浮点数，范围为90 ~ -90
                var longitude = data.longitude; // 经度，浮点数，范围为180 ~ -180。
                // 微信返回的是 gps 坐标

                var speed = data.speed; // 速度，以米/每秒计
                var accuracy = data.accuracy; // 位置精度
                position = {
                  gps: {
                    lng: longitude,
                    lat: latitude
                  },
                  point: {
                    lng: longitude,
                    lat: latitude
                  }
                };
                if (This.afterInitCurrentPosition) {
                  This.afterInitCurrentPosition(position);
                }else{
                  This.applyCallbacks(true);
                }
              },
              fail: function(data){
                // alert("从微信获取地理位置失败：" + JSON.stringify(data) + ", 尝试获取近似位置");
                // 尝试从腾讯地图获取
                log('fallback to use tencent map');
                This.fetchCurrentLocationByTMap();
              },
              complete: function(data){
                // 所有情况都到这
                log("getLocation complete", data);
              },
              cancel: function(data){
                // 不授权
                log("getLocation cancel", data);
              }
            });
          });
        }else{
          // 非微信环境，使用腾讯地图根据 IP 返回一个大概的位置
          This.fetchCurrentLocationByTMap();
        }
      },

      fetchCurrentLocationByTMap: function(){
        var This = this;
        log('initCurrentPosition by tencent map');
        if (typeof qq == 'undefined' || typeof qq.maps == 'undefined'){
          window._ng_callback_geolocation_service = function(){
            This.getCurrentLocationByTMap();
            delete window._ng_callback_geolocation_service
          };
          (function(document, tag) {
            var scriptTag = document.createElement(tag), // create a script tag
              firstScriptTag = document.getElementsByTagName(tag)[0]; // find the first script tag in the document
            scriptTag.src = 'http://map.qq.com/api/js?v=2.exp&libraries=convertor&callback=_ng_callback_geolocation_service'; // set the source of the script to your script
            firstScriptTag.parentNode.insertBefore(scriptTag, firstScriptTag); // append the script to the DOM
          }(document, 'script'));
          // $.getScript("http://map.qq.com/api/js?v=2.exp&libraries=convertor&callback=_ng_callback_geolocation_service");
        }else{
          this.getCurrentLocationByTMap();
        }
      },

      //
      // 用腾讯地图获取地理位置信息，用在非微信环境，仅 Web 端测试。
      //
      getCurrentLocationByTMap: function(){
        var This = this;
        new qq.maps.CityService({
          complete : function(result){
            log('initCurrentPosition', result);
            var myPoint = result.detail.latLng;
            position = {
              point: {
                lng: myPoint.getLng(),
                lat: myPoint.getLat()
              }
            }
            if (This.afterInitCurrentPosition){
              This.afterInitCurrentPosition(position);
            }else{
              This.applyCallbacks(true);
            }
          }
        }).searchLocalCity();
      },

      applyCallbacks: function (apply) {
        positionReady = true; // callback 被调用，说明位置信息已经准备好了。
        log('apply callbacks: length=', callbacks.length);
        while (callbacks.length > 0) {
          var callback = callbacks.shift();
          if (apply){
            $timeout(function(){
              try {
                callback(position);
              }catch(e){
                log('execute callback error: ' + callback.toString());
              }
            },0);
          }else{
            try {
              callback(position);
            }catch(e){
              log('execute callback error: ' + callback.toString());
            }
          }
        }
      },

      initCurrentPositionRoutine: function () {
        log('initCurrentPositionRoutine start, name=' + this.name);
        var This = this;
        if (This.isInitialized()) {
          this.initCurrentPosition();
        } else {
          This.initDaemon = $interval(function () {
            if (This.isInitialized()) {
              log('initCurrentPosition clear daemon');
              $interval.cancel(This.initDaemon);
              This.initCurrentPosition();
            }
          }, This.daemonInterval);
        }
      }
    };

    var TMapManager = angular.extend(angular.extend({}, MapManager), {
      name: '腾讯地图',
      supportAddress: true,

      isInitialized: function(){
        return (typeof qq != 'undefined') && (typeof qq.maps != 'undefined');
      },

      // 据经纬查询地址
      afterInitCurrentPosition: function (position) {
        var This = this;
        log("convert gps location start", position)
        // 如果从微信获取到 gps 坐标，需要进行转换
        if (position.gps){
          var gpsLatLng = new qq.maps.LatLng(position.gps.lat, position.gps.lng)
          qq.maps.convertor.translate(gpsLatLng, 1, function (tcLatLngArray) {
            log("convert to tencent coords success", tcLatLngArray);
            position.point.lat = tcLatLngArray[0].lat
            position.point.lng = tcLatLngArray[0].lng
            This.geocode(position);
          });
        }else{
          This.geocode(position);
        }
      },

      geocode: function(position){
        log("getGeocoding start", position);
        var This = this;
        var geocoder = new qq.maps.Geocoder();
        var point = position.point;
        var latLng = new qq.maps.LatLng(point.lat, point.lng);
        //设置服务请求成功的回调函数
        geocoder.setComplete(function (result) {
          log('getGeocoding returns', result);
          //{
          //  result:
          //    type: "GEO_INFO",
          //    detail:
          //      address: "中国上海市黄浦区人民大道200号"
          //      addressComponents:
          //        city: "上海市"
          //        country: "中国"
          //        district: "黄浦区"
          //        province: "上海市"
          //        street: "人民大道"
          //        streetNumber: "人民大道200号"
          //        town: "彭浦镇"
          //        village: "泥成桥"
          //}
          var comps = result.detail.addressComponents;
          var prefix = comps.country + comps.province + comps.city;
          if(result.detail.address.indexOf(prefix) == 0){
            result.detail.address = result.detail.address.substr(prefix.length);
          }
          position.address = {
            formatted_address: result.detail.address,
            country: comps.country,
            province: comps.province,
            city: comps.city,
            district: comps.district,
            street: comps.street,
            street_number: comps.streetNumber
          }
          This.applyCallbacks(true);
        });
        //若服务请求失败，则运行以下函数
        geocoder.setError(function () {
          This.supportAddress = false;
          This.applyCallbacks(true);
        });
        //对指定经纬度进行解析
        geocoder.getAddress(latLng);
      }
    });

    //
    // 这里实际上没有用到谷歌地图。但期望用的是谷歌地图，故如此设置
    //
    var GMapManager = angular.extend(angular.extend({}, MapManager), {

      name: '谷歌地图',
      supportAddress: true,
      // 这个地址后面应该拼接 lat,lng 无空格
      geocodingRequestUrl: "http://maps.googleapis.com/maps/api/geocode/json?sensor=true&&latlng=",
      geocoder: null,

      isInitialized: function () {
        return typeof google != 'undefined' && typeof google.maps != 'undefined';
      },

      //
      // 获得地理编码信息
      // google 的地理编码与百度不同，需要进行细致的转换
      //
      getGeocoding: function (point, success, error) {
        log('getGeocoding start', point);
        if (this.geocoder == null) {
          this.geocoder = new google.maps.Geocoder();
        }
        var latlng = new google.maps.LatLng(point.lat, point.lng);
        this.geocoder.geocode({'latLng': latlng}, function (results, status) {
          if (status == google.maps.GeocoderStatus.OK) {
            log('getGeocoding returns', results);
            if (results[0]) {
              var result = results[0];

              // search valid entries
              var valid = false;
              angular.forEach('street_address route locality political'.split(' '), function(it){
                if (result.types.indexOf(it) >= 0){
                  valid = true;
                }
              });
              if (valid) {
                // build address
                var address = {
                  formatted_address: result.formatted_address
                };
                angular.forEach(result.address_components, function (elem) {
                  var types = elem.types;
                  // 对应关系，从 geocoding 例子中摘出。每个字段有 long_name 和 short name
                  // postal_code 邮编
                  // [ "country", "political" ]
                  // [ "administrative_area_level_1", "political" ]
                  // [ "administrative_area_level_2", "political" ]
                  // [ "administrative_area_level_3", "political" ]
                  // [ "locality", "political" ] ~ city
                  // [ "sublocality_level_1", "sublocality", "political"] ~ district
                  // route ~ street
                  // street_number
                  if (!(types instanceof Array)) {
                    types = [types];  // convert to array
                  }

                  if (types.indexOf('country') >= 0) {
                    address.country = elem.long_name;
                  } else if (types.indexOf('administrative_area_level_1') >= 0) {
                    address.province = elem.long_name;
                  } else if (types.indexOf('administrative_area_level_2') >= 0) {
                    // 无对应
                  } else if (types.indexOf('administrative_area_level_3') >= 0) {
                    // 无对应
                  } else if (types.indexOf('locality') >= 0) {
                    address.city = elem.long_name;
                  } else if (types.indexOf('sublocality_level_1') >= 0) {
                    address.district = elem.long_name;
                  } else if (types.indexOf('route') >= 0) {
                    address.street = elem.long_name;
                  } else if (types.indexOf('street_number') >= 0) {
                    address.street_number = elem.long_name;
                  }
                });
                //
                // formatted_address 去掉 street_number，以方便位置匹配
                //
                if (address.street_number) {
                  address.formatted_address = address.formatted_address.replace(address.street_number, "");
                }
                log('getGeocoding build address:', address);
                if (success) {
                  success(address);
                  return;
                }
              } else {
                alert('getGeocoding invalid result type')
                log('getGeocoding invalid result type');
              }
            } else {
              alert('getGeocoding no results')
              log('getGeocoding no results');
            }
          } else {
            alert('getGeocoding falied' + status);
            log('getGeocoding falied', status);
          }
          if (error) {
            error();
          }
        });
      },

      afterInitCurrentPosition: function (position) {
        var This = this;
        this.getGeocoding(position.point, function (address) {
          position.address = address;
          This.applyCallbacks();
        }, function () {
          alert('查询谷歌地图信息失败')
          This.supportAddress = false;
          This.applyCallbacks();
        });
      }
    });

    //
    // 初始化
    //
    ShopService.get(function (shop) {
      debug = shop.debug;
      if (shop.enable_foreign) {
        mgr = GMapManager;
      } else {
        mgr = TMapManager;
      }
      mgr.initCurrentPositionRoutine();
    });

    var upload_user_location = function (position) {
      var lat = position.point.lat;
      var lng = position.point.lng;
      var city_name;
      if (mgr.supportAddress) {
        city_name = position.address.formatted_address;
      } else {
        city_name = DEFAULT_CITY_NAME;
      }
      var User = $resource(DdtConst.baseUrl + '/user/:action', {format: 'json'}, {
        update_location: {method: 'POST', params: {action: 'update_location', nomask: true}}
      });
      var location_data = {
        latitude: lat,
        longitude: lng,
        city_name: city_name
      };
      User.update_location({}, {
        user: location_data
      }, function(user){
        $rootScope.$emit("events:update_location", location_data);
      })
    };

    callbacks.push(upload_user_location);

    var syncDistance = function (coords, success) {
      if (positionReady) {
        var dist = geolib.getDistance(
          {latitude: position.point.lat, longitude: position.point.lng},
          {latitude: coords.latitude, longitude: coords.longitude}
        );
        success(dist);
        return dist;
      } else {
        return false;
      }
    };

    var city_name = function (success) {
      if (positionReady && mgr.supportAddress) {
        var city_name = "定位中";
        angular.forEach('country province city district'.split(' '), function(it){
          if (position.address && position.address[it]){
            city_name = position.address[it];
          }
        });
        success(city_name);
        return city_name;
      } else {
        return false;
      }
    }
    var location_address = function (success) {
      if (positionReady) {
        var city = DEFAULT_CITY_NAME;
        if (mgr.supportAddress && position.address && position.address.city){
          city = position.address.city;
        }
        var location_address = {
          lat: position.point.lat,
          lng: position.point.lng,
          city: city
        }
        success(location_address);
        return location_address;
      } else {
        return false;
      }
    }

    var distance = function (coords, success) {
      if (false == syncDistance(coords, success)) {
        callbacks.push(function (position) {
          syncDistance(coords, success);
        });
      }
    };

    var get_city_name = function (success) {
      if (false == city_name(success)) {
        callbacks.push(function (position) {
          city_name(success);
        });
      }
    }

    var get_location_address = function (success) {
      if (false == location_address(success)) {
        callbacks.push(function (position) {
          location_address(success);
        });
      }
    }

    var get_current_position = function(success){
      if (!positionReady){
        callbacks.push(success);
      }else{
        success(position);
      }
    }
    // 目前只用于开启外国运营的客户
    var code_address = function(address, success, fail){
      geocoder = new google.maps.Geocoder();
      geocoder.geocode( { 'address': address}, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        var pos = results[0].geometry.location;
        success(pos);
      } else {
        fail(status);
      }
    });
    }

    // 地址查询
    function search_address(keyword, region, success) {
      if (region) {
        var searchService = new qq.maps.SearchService({
          complete: function (results) {
            var pois = results.detail.pois;
            success(pois)
          }
        });
        searchService.setLocation(region)
        searchService.setPageIndex(0);
        searchService.setPageCapacity(15);
        searchService.search(keyword);
      } else {
        console.error('查询腾讯地图需要输入地区')
      }
    }

    function search_address_by_google(keyword, success) {
      var lat,lng;
      if (position) {
        lat = position.point.lat
        lng = position.point.lng
      } else {
        lat = -33.8665;
        lng = 151.1956;
      }
      var pyrmont = new google.maps.LatLng(lat, lng);
      var map = new google.maps.Map(document.getElementById('weixin_google_map'), {
        center: pyrmont,
        zoom: 15
      });

      var request = {
        location: pyrmont,
        radius: '500',
        query: keyword
      };

      var service = new google.maps.places.PlacesService(map);
      service.textSearch(request, function(result, status){
        if (status == google.maps.places.PlacesServiceStatus.OK) {
          var addresses = []
          angular.forEach(result, function(item){
            addresses.push({
              name: item.name,
              latLng: {
                lat: item.geometry.location.lat(),
                lng: item.geometry.location.lng()
              }
            });
          });
          success(addresses)
        }
      });
    }

    return {
      distance: distance,
      get_city_name: get_city_name,
      get_location_address: get_location_address,
      get_current_position: get_current_position,
      code_address: code_address,
      search_address: search_address,
      search_address_by_google: search_address_by_google
    }
  }])
;
