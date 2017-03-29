WebposModules.add_action('set_fastfood_extended_form');
angular.module('webpos.actions.set_fastfood_extended_form', [])
  .factory('SetFastfoodExtendedForm',
    ['$timeout', 'ExtendedFormService', 'FastfoodFormService',
      function ($timeout, ExtendedFormService, FastfoodFormService) {
        return function set_fastfood_extended_form(options) {
          var $scope = options.scope
          var cart_attribute_identifier = options.model_name || 'cart'
          var reload = options.reload
          if (reload == undefined){
            reload = true
          }

          var clear_cart_monitor;
          if (FastfoodFormService.has_object()) {
            FastfoodFormService.get_images_files().then(function (imageFiles) {
              FastfoodFormService.get_images_interval().then(function (interval) {
                // initialize fast food extended form
                if (reload) {
                  (function initialize_fast_food_extended_form() {
                    var html = $(".extended-form-fastfood-cart")
                      .attr("data-images", JSON.stringify(imageFiles))
                      .attr("data-interval", interval)[0].outerHTML
                    // inject css
                    var cssTag = $('<link>')
                      .attr("href", $('meta[name="extended_form_css_url"]').attr("content"))
                      .attr("media", "all")
                      .attr("type", "text/css")
                      .attr("rel", "stylesheet")[0].outerHTML;
                    var jsTag = $("<script>")
                      .attr("src", $('meta[name="extended_form_js_url"]').attr("content"))
                      .attr("type", "text/javascript")[0].outerHTML;
                    html = html + cssTag + jsTag
                    ExtendedFormService.load_html(html)
                  })();
                }

                clear_cart_monitor = $scope.$watchGroup([cart_attribute_identifier + ".item_count", cart_attribute_identifier + ".total"], function () {
                  $scope._wpffcart = $scope[cart_attribute_identifier]
                  $scope._wpffcart_adjustment_total = undefined
                  $scope._wpffcart_item_total = undefined
                  if ($scope._wpffcart) {
                    var info_items = $scope._wpffcart.info_items;
                    if (info_items) {
                      _.each(info_items, function (item) {
                        if (item.name == '折扣合计') {
                          $scope._wpffcart_adjustment_total = Math.abs(item.value);
                        } else if (item.name == '订单合计') {
                          $scope._wpffcart_item_total = item.value;
                        }
                      });
                    }
                  }

                  $timeout(function update_fast_food_extended_form() {
                    window.postMessage({
                      type: 'webpos:clientview:delegate',
                      data: {
                        type: 'webpos:fastfood:updateCart',
                        html: $('.ff-item-container', $(".extended-form-fastfood-cart")).html()
                      }
                    }, '*')
                  }, 100);
                });
              });
            });
          }

          $scope.$on("$destory", function () {
            if (clear_cart_monitor) {
              clear_cart_monitor();
            }
          });
        };
      }])
