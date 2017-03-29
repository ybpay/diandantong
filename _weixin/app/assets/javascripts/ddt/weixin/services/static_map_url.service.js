Ddt.factory('StaticMapUrlService', ['ShopService', function(ShopService){
/*
===tencent markers===
http://st.map.qq.com/api?size=604*300&center=116.31993,40.03304&zoom=13&
markers=116.31993,40.03304,1|116.31634,40.02369,2

===tencent paths===
paths=color:0x0000FF,weight:5,116.31993,40.03304,116.31634,40.02369

===google marker===
https://maps.googleapis.com/maps/api/staticmap?center=Brooklyn+Bridge,New+York,NY&zoom=13&size=600x300&maptype=roadmap
&markers=color:blue%7Clabel:S%7C40.702147,-74.015794&markers=color:green%7Clabel:G%7C40.711614,-74.012318
&markers=color:red%7Clabel:C%7C40.718217,-73.998284

===google path===
path=color:0x0000ff|weight:5|40.737102,-73.990318|40.749825,-73.987963|40.752946,-73.987384|40.755823,-73.986397
*/
  var map_type = null;
  var use_gmap = null;
  var GOOGLE_STMAP_API = "https://maps.googleapis.com/maps/api/staticmap?";
  var TENCENT_STMAP_API= "http://st.map.qq.com/api?";
  var ZOOM = "zoom=13";

  function size(){ return use_gmap ? "size=340x600" : "size=340*600"}
  function center(point){ return "center="+point_str(point)}
  function point_str(point){
    longitude = point.longitude;
    latitude = point.latitude;
    return use_gmap ? ""+latitude+","+longitude : ""+longitude+","+latitude;
  }
  function markers(points){
    last_point = points.pop();
    points.reverse();
    var str = use_gmap ? "" : "markers="

    mks = []
    while(points.length > 0){
      point = points.pop();
      pstr = use_gmap ? "markers=color:gray%7C" + point_str(point) : point_str(point)+",gray"
      mks.push(pstr);
    }
    last_point_str = use_gmap ? "markers=color:red%7Clabel:A%7C" + point_str(last_point) : point_str(last_point)+",red,A"
    mks.push(last_point_str)
    var separate_char = use_gmap ? "&" : "|"
    return str + mks.join(separate_char)
  }

  function init_map_type(){
    if(map_type == null){
      ShopService.get(function (shop) {
        use_gmap = shop.enable_foreign ? true : false;
      });
    }
  }

  function map_url(points){
    init_map_type();
    var api = use_gmap ? GOOGLE_STMAP_API : TENCENT_STMAP_API
    last_point = points[points.length-1]
    return api + [size(), center(last_point), ZOOM, markers(points)].join("&")
  }

  return {
    map_url: map_url
  }
}])