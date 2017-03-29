Ddt.factory('LocationService', ['$rootScope', '$interval', '$resource', '$http', 'DdtConst', 'ShopService', 'GeolocationService', 
  function ($rootScope, $interval, $resource, $http, DdtConst, ShopService, GeolocationService) {

    var DEFAULT_LATITUDE  = 31.2235019388734
    var DEFAULT_LONGITUDE = 121.47994995117188
    var Map = null;
    var is_init_need_geolocate = null;

    var default_css = "cursor:pointer;border:1px solid rgba(255,255,0.5);border-right: 1px solid #aaa;border-bottom: 1px solid #aaa;text-align:center;"

    // 用于保存的dom对象
    var saveDomObj = document.createElement("div");
    saveDomObj.appendChild(document.createTextNode("使用此位置"));
    saveDomObj.style.cssText = default_css + "font-size:16px;font-weight:bold;line-height:40px;color:red;margin-right:12px;margin-bottom:30px;padding-left:8px;padding-right:8px;background-color:white;";


    var geolocationDomObj = document.createElement("div");
    geolocationDomObj.innerHTML = "<i class='fa fa-crosshairs'></i>"
    geolocationDomObj.style.cssText = default_css + "width:40px;height:40px;line-height:40px;font-size:16px;margin-left:12px;margin-top: 10px;background-color: white; font-size:20px;";

    //获取地理位置( 这里可能由于一些原因获取不到位置信息，那callback 就不会被调用 )
    var init_current_position = function(callback){
      GeolocationService.get_current_position(function(res){
        callback(res.point)
      });
    }

    var init_map = function(){
      if(Map == null){
        ShopService.get(function (shop) {
          if (shop.enable_foreign) {
            Map = GMap;
          } else {
            Map = TMap;
          }
        });  
      }
    }

    var show_picker = function(container_id, longitude, latitude, save){
      is_init_need_geolocate = false;
      if(longitude==null || latitude==null){ is_init_need_geolocate = true }
      var longitude = longitude || DEFAULT_LONGITUDE
      var latitude = latitude || DEFAULT_LATITUDE
      Map.show_picker(container_id, longitude, latitude, save);
    }

    
    // 腾讯地图
    var show_tmap_picker = function(container_id, longitude, latitude, save){

      var point = new qq.maps.LatLng(latitude, longitude)
      var address = "";
      var marker = null;

      var map = new qq.maps.Map(document.getElementById(container_id),{
        disableDoubleClickZoom: true
      });

      // 定位
      var geolocate = function(){
        init_current_position(function(p){
          point = new qq.maps.LatLng(p.lat, p.lng)
          refresh_marker(point);
        });
      }

      // 用于将坐标转换为地址信息
      var geocoder = new qq.maps.Geocoder({
        complete: function(result){
          address = result.detail.address;
        }
      })

      //定位控件
      geolocationDomObj.onclick = geolocate;

      var geolocationControl = new qq.maps.Control({
        content: geolocationDomObj,
        map: map,
        align: qq.maps.ALIGN.TOP_LEFT
      })

      //保存控件
      saveDomObj.onclick = function(e){
        save(point, address)
      }

      var saveControl = new qq.maps.Control({
        content: saveDomObj,
        map: map,
        align: qq.maps.ALIGN.BOTTOM_RIGHT
      })

      

      

      var refresh_marker = function(point){
        if(marker == null){
          marker = new qq.maps.Marker({ position: point, map: map});
        }else{
          marker.setPosition(point);
        }
        map.panTo(point);
        geocoder.getAddress(point);
      }

      //地图点击事件监听
      var clickHandle = function(e){
        point = new qq.maps.LatLng(e.latLng.lat, e.latLng.lng);
        refresh_marker(point);
      }
      var map_click_listener = qq.maps.event.addListener(map, 'click', clickHandle);

      // 地图初始化
      map.panTo(point)
      map.zoomTo(this.zoom_level);
      refresh_marker(point);
      if(is_init_need_geolocate){ 
        geolocate(); 
      }
    }

    //=========================================================================================
    // 谷歌地图
    var show_gmap_picker = function(container_id, longitude, latitude, save){

      var point = new google.maps.LatLng(latitude, longitude);
      var address = "";
      var marker = null;
      var map_options = {
        zoom: this.zoom_level,
        center: point
      }


      var map = new google.maps.Map(document.getElementById(container_id),map_options);
      
      // 定位
      var geolocate = function(){
        init_current_position(function(p){
          point = new google.maps.LatLng(p.lat, p.lng);
          refresh_marker(point);
          map.setCenter(point);
        })
      }
      // 刷新标记
      var refresh_marker = function(point){
        if(marker==null){
          marker = new google.maps.Marker({position: point, map: map });
        }else{
          marker.setPosition(point);
        }
      }

      // 地图点击事件
      map.addListener('click', function(e){
        point = new google.maps.LatLng(e.latLng.lat(), e.latLng.lng());
        refresh_marker(point);
        map.setCenter(point);
      });

      
      saveDomObj.index = 1;
      saveDomObj.onclick = function(e){
        var p = {
          lat: point.lat(),
          lng: point.lng()
        }
        save(p, address)
      }
      map.controls[google.maps.ControlPosition.RIGHT_BOTTOM].push(saveDomObj);

      //
      geolocationDomObj.index = 1;
      geolocationDomObj.onclick = geolocate;
        
      map.controls[google.maps.ControlPosition.LEFT_TOP].push(geolocationDomObj);
      
      refresh_marker(point);
      if(is_init_need_geolocate){ geolocate(); }
    }

    var TMap = {
      zoom_level: 13,
      show_picker: show_tmap_picker
    }

    var GMap = {
      zoom_level: 15,
      show_picker: show_gmap_picker
    }

    // 初始化地图
    init_map();

    return {
      show_picker: show_picker
    }
}]);