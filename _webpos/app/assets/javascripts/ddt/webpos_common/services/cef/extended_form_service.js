WebposModules.add_service('extended_form')
angular.module('webpos.services.extended_form',[]).
  factory('ExtendedFormService', ['$rootScope', 'WebposObjectAsyncAdapter',
    function($rootScope, WebposObjectAsyncAdapter){

      var object = WebposObjectAsyncAdapter.create({
        obtain_service: function(){
          return window.ExtendedFormObject;
        }
      });


      function has_object(){
        return object.has_object();
      }

      function show(){
        return object.if_enable(function(){
          return object.show()
        })
      }

      function hide(){
        return object.if_enable(function(){
          return object.load_url("").then(function(){
              return object.hide()
            });
        });
      }

      function get_extended_form_enable(){
        return object.if_enable(function(){
          return object.get_extended_form_enable()
        })
      }

      function set_extended_form_enable(e) {
        return object.if_enable(function(){
          return object.set_extended_form_enable(e)
        });
      }

      function load_url(url){
        return object.if_enable(function(){
          return object.load_url(url)
        });
      }
      function load_html(html){
        return object.if_enable(function(){
          return object.load_html(html)
        });
      }

      function show_order(order_id){
        return object.if_enable(function(){
          return object.load_url("/webpos/extended_form/shops/" + $rootScope.shop.id + "/orders/" + order_id).then(function(){
            return object.show();
          });
        });
      }

      function show_qrcode(text, qrcode_url){
        return object.if_enable(function(){
          return object.load_html("<html><body style='height:100%;overflow:hidden; width: 100%;'><div style='text-align:center;padding: 1em;'><div style='font-size: 1.5em;'>"+text+"</div><img src='"+qrcode_url+"' style='width:450px; max-width: 60%;'></img></div></body></html>").then(function(){
            return object.show();
          })
        })
      }

      function show_wechat_account_qrcode(gonghao_open_id){
        return show_qrcode("使用微信“扫一扫”功能，关注本店公众号进行微信自助下单", "http://open.weixin.qq.com/qr/code/?username=" + gonghao_open_id)
      }

      function show_hint(text){
        return object.if_enable(function(){
          return object.load_html("<html><body style='height:100%;overflow:hidden;'><div style='text-align:center;padding-top:10%;'><h1>"+text+"</h1></div></body></html>").then(function(){
            return object.show();
          });
        });
      }

      return window.ExtendedFormService = {
        has_object: has_object,
        show:show,
        hide:hide,
        get_extended_form_enable: get_extended_form_enable,
        set_extended_form_enable: set_extended_form_enable,
        load_url: load_url,
        load_html: load_html,
        show_order:show_order,
        show_qrcode: show_qrcode,
        show_wechat_account_qrcode: show_wechat_account_qrcode,
        show_hint: show_hint
      }
    }]);