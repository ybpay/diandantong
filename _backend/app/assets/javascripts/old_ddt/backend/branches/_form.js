// 这段代码需要在创建或编辑门店时执行，但是校验不通过时服务端返回的页面路径不以new或edit结尾。
// 因此将判断条件去掉，在所有页面加载代码。
//if (/\/backend\/shops\/.*?\/branches\/(new|(.*?\/edit))/.test(location.pathname)) {
  $(function () {

    function initPicker(mapType) {
      var formLng = $('#branch_longitude');
      var formLat = $('#branch_latitude');
      var formAddr = $('#branch_address');
      var lngElem = $('#modal-longitude');
      var latElem = $('#modal-latitude');
      var addrElem = $('#modal-address');

      var container_id = "cords-selector-map";
      var map = null;       // 地图对象
      var curMarker = null; // 当前选中的点

      //================================================================
      // common map manager
      //================================================================

      var MapMgr = {
        isInitialized: function(){return true;},
        getMyPoint: function(callback){},
        showPicker: function(container_id, myPoint, onPick){},
        onPick: function(point){},
        refreshMarker: function(point){},
        ensureInitialized: function(callback){
          var This = this;
          var iId = setInterval(function () {
            if (This.isInitialized()){
              clearInterval(iId);
              console.info('map object initialized');
              callback();
            }
          }, 100);
          return false;
        },

        run: function(){
          var This = this;
          this.ensureInitialized(function(){
            $('#link-open-picker').on('click', function () {
              lngElem.html(formLng.val());
              latElem.html(formLat.val());

              This.getMyPoint(function (myPoint) {
                This.showPicker(container_id, myPoint);
              });
            });

            $('#btn-save-point').on('click', function () {
              formLng.val(lngElem.html());
              formLat.val(latElem.html());
              if (formAddr.val().length == 0) {
                formAddr.val(addrElem.html());
              }
            });
          });
        },

        getPreSetLatLng: function(){
          var lng = parseFloat(lngElem.html());
          var lat = parseFloat(latElem.html());
          if (!isNaN(lat) && !isNaN(lng)) {
            return {
              lat: lat,
              lng: lng
            }
          }else{
            return null;
          }
        }
      }

      //================================================================
      // google map
      //================================================================

      var GMapMgr = $.extend({},MapMgr);
      GMapMgr = $.extend(GMapMgr, {

        isInitialized: function(){
          return (typeof google != 'undefined') && (typeof google.maps != 'undefined');
        },

        getMyPoint: function(callback){
          var latLng = this.getPreSetLatLng();
          var myPoint;
          if (latLng){
            myPoint = new google.maps.LatLng(latLng.lat,latLng.lng);
            callback(myPoint);
          }else{
            if (navigator.geolocation) {
              navigator.geolocation.getCurrentPosition(function (position) {
                myPoint = new google.maps.LatLng(position.coords.latitude,
                  position.coords.longitude);
                lngElem.html(position.coords.longitude);
                latElem.html(position.coords.latitude);
                callback(myPoint);
              }, function () {
                alert('自动获取地理位置失败，请手动设置。')
              });
            } else {
              alert('您的浏览器不支持获得地理位置，请手动设置。')
            }
          }
        },

        showPicker: function(container_id, myPoint) {
          var This = this;
          if (map == null) {
            var mapOptions = {
              zoom: 7
            }
            map = new google.maps.Map(document.getElementById(container_id), mapOptions);
            map.addListener('click', function (e) {
              console.info('当前位置' + e.latLng.lng() + ',' + e.latLng.lat());
              This.onPick(e.latLng);
            });
          }
          map.setCenter(myPoint);
          This.refreshMarker(myPoint);
        },

        onPick: function(point){
          lngElem.html(point.lng());
          latElem.html(point.lat());
          new google.maps.Geocoder().geocode({'latLng': point}, function(results, status) {
            if (status == google.maps.GeocoderStatus.OK && results[0]) {
              addrElem.html(results[0].formatted_address);
            } else {
              addrElem.html("");
            }
          });

          this.refreshMarker(point);
        },

        refreshMarker: function(point){
          if (curMarker == null) {
            curMarker = new google.maps.Marker({position: point, map: map});
          } else {
            curMarker.setPosition(point);
          }
        }
      });

      //================================================================
      // baidu map
      //================================================================


      var BMapMgr = $.extend({}, MapMgr);
      BMapMgr = $.extend(BMapMgr, {

        isInitialized: function(){
          return typeof BMap != 'undefined';
        },

        getMyPoint: function(callback) {
          var latLng = this.getPreSetLatLng();
          var myPoint;
          if (latLng) {
            myPoint = new BMap.Point(latLng.lng, latLng.lat);
            callback(myPoint);
          } else {
            var geolocation = new BMap.Geolocation();
            geolocation.getCurrentPosition(function (data) {
              if (this.getStatus() == BMAP_STATUS_SUCCESS) {
                myPoint = data.point;
                lngElem.html(myPoint.lng);
                latElem.html(myPoint.lat);
                callback(myPoint);
              }
            });
          }
        },

        showPicker: function(container_id, myPoint){
          var This = this;
          if (map == null) {
            map = new BMap.Map(container_id);
            map.enableScrollWheelZoom();
            map.addEventListener("click", function (e) {
              console.info('当前位置 ' + e.point.lng + ', ' + e.point.lat);
              This.onPick(e.point);
            });
          }
          map.centerAndZoom(point, 10);
          This.refreshMarker(myPoint);
        },

        onPick: function(point){
          lngElem.html(point.lng);
          latElem.html(point.lat);
          this.refreshMarker(point);
        },

        refreshMarker: function(point){
          if (curMarker != null) {
            map.removeOverlay(curMarker);
          }
          curMarker = new BMap.Marker(point);
          map.addOverlay(curMarker);
        }
      });




      //================================================================
      // tencent map
      //================================================================

      var TMapMgr = $.extend({}, MapMgr);
      TMapMgr = $.extend(MapMgr, {
        isInitialized: function(){
          return (typeof qq != 'undefined') && (typeof qq.maps != 'undefined');
        },

        getMyPoint: function(callback){
          var latLng = this.getPreSetLatLng();
          var myPoint;
          if (latLng) {
            myPoint = new qq.maps.LatLng(latLng.lat, latLng.lng);
            callback(myPoint);
          } else {
            new qq.maps.CityService({
              complete : function(result){
                myPoint = result.detail.latLng;
                lngElem.html(myPoint.getLng());
                latElem.html(myPoint.getLat());
                callback(myPoint);
              }
            }).searchLocalCity();
          }
        },

        showPicker: function(container_id, myPoint){
          var This = this;
          if (map == null) {
            map = new qq.maps.Map(document.getElementById(container_id), {
              zoom: 10,
              center: myPoint
            });
            qq.maps.event.addListener(map, "click", function(e){
              var point = e.latLng;
              console.info('当前位置 ' + point.getLng() + ', ' + point.getLat());
              This.onPick(point);
            });
          }
          map.setCenter(myPoint);
          This.refreshMarker(myPoint);
        },

        onPick: function(point){
          lngElem.html(point.getLng());
          latElem.html(point.getLat());
          new qq.maps.CityService({
            complete: function(result) {
              var address;
              // 腾讯地图文档中使用result.detail.name，但是只精确到省,
              // result.detail.detail精确到区县，优先使用。
              if (result.detail.detail && result.detail.detail.length > 0) {
                // result.detail.detail的格式形如 "嘉定区,上海市,中国"
                address = result.detail.detail.split(',').reverse().join('');
              } else {
                address = result.detail.name;
              }
              addrElem.html(address);
            }
          }).searchCityByLatLng(point);

          this.refreshMarker(point);
        },

        refreshMarker: function(point){
          if (curMarker == null){
            curMarker = new qq.maps.Marker({
              position: point,
              map: map
            });
          }else{
            curMarker.setPosition(point);
          }

        }
      });


      //================================================================
      // map selector
      //================================================================


      switch(mapType){
        case 'GMap': mgr = GMapMgr; break;
        case 'BMap': mgr = BMapMgr; break;
        case "TMap": mgr = TMapMgr; break;
        default: alert('不支持该类型的地图。');
      }

      if (mgr){
        mgr.run();
      }
    }
    window.initPicker = initPicker;
  });
//}
