WebposModules.add_service('product')
angular.module('webpos.services.product', []).
  factory('ProductService',
    ['$resource', '$q', '$filter', 'BranchService', 'VersionedCache',
    function($resource, $q, $filter, BranchService, VersionedCache){

    var Product = $resource('/branches/:branch_id/products/:id/:action',{},{
      query: { method: 'get', isArray: true }
    })

    var products_cache = {};
    function init_products_cache(){
      products_cache  = {
        confirm_exist: function(branch_id){
          if(this[branch_id] == undefined){
            var cache = VersionedCache.create(branch_id, 'products', BranchService.cache_versions(branch_id).products);
            cache.valid = function(order_type_str){
              if(cache.objs && cache.objs.length > 0){
                var replace_str = $filter('date')(new Date(), "THH:mm:ss.000+")
                var current_time= Date.parse(cache.objs[0].start_time.replace(/T.+\+/, replace_str))
                return _.filter(cache.objs, function(p){
                  var type_valid = (typeof order_type_str == 'undefined' ? true : p['support_'+order_type_str]);
                  /* !p.estimate_clear */
                  return p.on_shelf && type_valid && Date.parse(p.start_time) < current_time && current_time < Date.parse(p.end_time)
                })
              }else{
                return []
              }
            }
            this[branch_id] = cache;
          }
        }
      };
    }
    init_products_cache();

    var page_limit = 20;
    var is_loading = false;

    function queryAll(branch_id, skip_mask){
      var defer = $q.defer();
      if(!skip_mask){
        skip_mask = false;
      }
      if(cacheValid(branch_id)){
        defer.resolve(products_cache[branch_id].valid());
      }else if(!is_loading){
        is_loading = true;
        var query_params = {
          branch_id: branch_id,
          per_page: page_limit,
          page: 1,
          skip_mask: skip_mask
        }
        if(products_cache[branch_id].objs){
          query_params['q[updated_at_gteq]'] = get_latest_updated_at(branch_id)
        }
        loadNextPage(query_params)
        .then(function(products){
          is_loading = false;
          products_cache[branch_id].version = BranchService.cache_versions(branch_id).products;
          products_cache[branch_id].store();
          defer.resolve(products);
        }).catch(function(error){
          console.error("无法加载菜品，出错原因："+error);
          defer.reject("无法加载菜品，出错原因："+error);
          is_loading = false;
        });
      }else {
        console.error("正在加载产品，不要同时多次加载....");
        defer.reject('正在加载产品，不要同时多次加载....');
      }
      return defer.promise;
    }

    function get_latest_updated_at(branch_id){
      var last_updated_at = new Date(0)
      if(products_cache[branch_id].objs.length > 0){
        var max = Date.parse(last_updated_at)
        angular.forEach(products_cache[branch_id].objs, function(p){
          if(Date.parse(p.updated_at) > max){
            max = Date.parse(p.updated_at)
          }
        })
        last_updated_at = max;
      }
      return $filter('date')(last_updated_at, "yyyy-MM-dd HH:mm:ssZ")
    }

    function clear(branch_id){
      var defer = $q.defer();
      if(branch_id && products_cache[branch_id]){
        products_cache[branch_id].destroy();
        products_cache[branch_id] = undefined;
      }else if(!branch_id){
        init_products_cache();
      }
      defer.resolve();
      return defer.promise;
    }

    function filterProducts(cacheOfProduct, name_abbr_like){
      var products = [];
      if(name_abbr_like){
        name_abbr_like = name_abbr_like.toLowerCase();
      }
      var products1 = [];
      var products2 = [];
      var products3 = [];
      var index = -1;
      _.forEach(cacheOfProduct, function(product){
        if(product.name_abbr == name_abbr_like){
          products1.push(product);
          return;
        }else{
          index  = product.name_abbr.indexOf(name_abbr_like);
          if(index == 0){
            products2.push(product);
            return ;
          }else if(index > 0){
            products3.push(product);
            return;
          }
        }

        // if(product.name == name_abbr_like){
        //   products1.push(product);
        //   return;
        // }else{
        //   index  = product.name.indexOf(name_abbr_like);
        //   if(index == 0){
        //     products2.push(product);
        //     return ;
        //   }else if(index > 0){
        //     products3.push(product);
        //     return;
        //   }
        // }

        if(product.sku == name_abbr_like){
          products1.push(product);
          return;
        }else{
          index  = product.sku.indexOf(name_abbr_like);
          if(index == 0){
            products2.push(product);
            return ;
          }else if(index > 0){
            products3.push(product);
            return;
          }
        }
      })
      products = products.concat(products1);
      products = products.concat(products2);
      products = products.concat(products3);
      return _.uniqBy(products, 'id');
    }

    function findById(cacheOfProduct, product_id){
      var product = null;
      _.forEach(cacheOfProduct, function(p){
        if(p.id == product_id){
          product = p
        }
      })
      return product;
    }

    function queryByNameAbbr(branch_id, name_abbr_like){
      var defer = $q.defer();
      if(cacheValid(branch_id)){
        var products = filterProducts(products_cache[branch_id].valid(), name_abbr_like);
        defer.resolve(products);
      }else{
        queryAll(branch_id)
        .then(function(){
          var products = filterProducts(products_cache[branch_id].valid(), name_abbr_like);
          defer.resolve(products);
        })
      }
      return defer.promise;
    }

    function queryById(branch_id, id){
      var defer = $q.defer();
      if(cacheValid(branch_id)){
        var product = findById(products_cache[branch_id].valid(), id)
        defer.resolve(product)
      }else{
        queryAll(branch_id)
        .then(function(){
          var product = findById(products_cache[branch_id].valid(), id)
          defer.resolve(product)
        })
      }
      return defer.promise;
    }

    function query(branch_id, category_id){
      var defer = $q.defer();
      if(cacheValid(branch_id)){
        var products = _.filter(products_cache[branch_id].valid(), function(product){
          return _.indexOf(product.category_ids, category_id) >= 0;
        });
        defer.resolve(products);
      }else{
        queryAll(branch_id)
        .then(function(){
          var products = _.filter(products_cache[branch_id].valid(), function(product){
            return _.indexOf(product.category_ids, category_id) >= 0;
          });
          defer.resolve(products);
        })
      }
      return defer.promise;
    }

    function loadNextPage(params){
      var branch_id = params.branch_id
      var defer = $q.defer();
      Product
          .query(params)
          .$promise
          .then(function(products){
              products_cache.confirm_exist(branch_id)
              products_cache[branch_id].batch_update(products)
              if(products.length >= page_limit){
                params.page++
                defer.resolve(loadNextPage(params));
              }else{
                defer.resolve(products_cache[branch_id].objs);
              }
          });
      return defer.promise;
    }

    function updateCache(branch_id, product){
      products_cache.confirm_exist(branch_id)
      products_cache[branch_id].update(product)
      products_cache[branch_id].store()
    }

    function set_estimate_clear(branch_id, msg){
      var estimate_clear = ('add' == msg.action ? true : false)
      var product_id = msg.product_id;
      var variant_id = msg.variant_id;
      var defer = $q.defer();
      var version = parseInt(msg.cache_version);
      products_cache.confirm_exist(branch_id)
      if(products_cache[branch_id].objs){
        angular.forEach(products_cache[branch_id].objs, function(product){
          if(product.id == parseInt(product_id)){
            if(variant_id && product.variants.length > 1){
              var all_estimate_clear = true
              angular.forEach(product.variants, function(variant){
                if(variant.id == parseInt(variant_id)){
                  variant.estimate_clear = estimate_clear
                }
                if(variant.estimate_clear == false){
                  all_estimate_clear = false
                }
              })
              product.estimate_clear = all_estimate_clear;
            }else{
              product.estimate_clear = estimate_clear
              product.variants[0].estimate_clear = estimate_clear
            }
            products_cache[branch_id].version = version;
            products_cache[branch_id].store()
          }
        })
      }
      defer.resolve()
      return defer.promise;
    }

    function need_sync(branch_id){
      products_cache.confirm_exist(branch_id)
      var now = new Date()
      var beginning_of_day = new Date(now.getFullYear(), now.getMonth(), now.getDate())
      return products_cache[branch_id].version < Date.parse(beginning_of_day)
    }

    function cacheValid(branch_id){
      products_cache.confirm_exist(branch_id)
      var version = BranchService.cache_versions(branch_id).products
      return products_cache[branch_id].is_latest(version);
    }

    return {
      queryAll: queryAll,
      query: query,
      queryByNameAbbr: queryByNameAbbr,
      queryById: queryById,
      clear: clear,
      updateCache: updateCache,
      set_estimate_clear: set_estimate_clear,
      need_sync: need_sync
    }
  }])
