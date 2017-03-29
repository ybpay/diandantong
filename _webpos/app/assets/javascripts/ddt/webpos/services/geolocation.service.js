WebposModules.add_service('geolocation');
angular.module('webpos.services.geolocation', [])
.factory('GeolocationService', [
  '$rootScope',
  function($rootScope) {

    return {
      get_address: get_address,
      search_address: search_address
    }

    function get_address(latitude, longitude, success){
      var latlng = new qq.maps.LatLng(latitude, longitude)
      var geocoder = new qq.maps.Geocoder();
      geocoder.setComplete(function(result){
        var comp = result.detail.addressComponents;
        success({
          province: comp.province,
          city: comp.city
        })
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
      })
      geocoder.getAddress(latlng);
    }

    function search_address(region, keyword, success){
      if(region){
        var searchService = new qq.maps.SearchService({
          complete: function(results){
            console.log(results.detail.pois)
            success(results.detail.pois)
          }
        });
        searchService.setLocation(region);
        searchService.setPageIndex(0);
        searchService.setPageCapacity(15);
        searchService.search(keyword)
      }else{
        console.error('region empty')
      }
    }
  }])
