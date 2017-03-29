WebposModules.add_action('edit_line_item');
angular.module('webpos.actions.edit_line_item', [])
.factory('EditLineItemAction', ['$rootScope', 'ProductService', function($rootScope, ProductService){
  function action(line_item, callback){
    $rootScope.edit_line_item_modal = {
      show: false,
      init: function(){
        if(line_item){
          this.is_combo_package   = line_item.itemable_type == 'Ddt::ComboPackage';
          this.is_variant_package = line_item.itemable_type == 'Ddt::VariantPackage';
          this.is_variant         = line_item.itemable_type == 'Ddt::Variant';
          this.quantity = this.is_variant_package ? line_item.weight : line_item.quantity;
          if(this.is_variant_package || this.is_variant){
            var This = this;
            ProductService.queryById($rootScope.branch_id, line_item.product_id)
              .then(function(product){
                if(product.variants.length == 1){
                  This.itemable_name = line_item.name
                }else{
                  This.itemable_id = line_item.itemable_id;
                  This.variants = product.variants;
                }
              })
          }else{
            this.itemable_name = line_item.name
          }
          this.focus_input();
          this.show = true;
        }else{
          $rootScope.alert('请选选择条目')
        }
      },
      focus_input: function(){
        $rootScope.select(".edit_line_item_modal input")
      },
      close: function(){
        this.show = false;
        $rootScope.edit_line_item_mdoal = undefined
      },
      can_submit: function(){
        var quantity = Number(this.quantity)
        if(typeof quantity == "number" && quantity > 0){
          if(this.is_variant || this.is_combo_package){
            return quantity % 1 == 0
          }else{
            return true;
          }
        }else{
          return false;
        }
      },
      submit: function(){
        if(this.can_submit()){
          if(callback){
            if(this.is_variant_package){
              line_item.weight = Number(this.quantity)
            }else{
              line_item.quantity = Number(this.quantity)
            }
            if(this.variants){
              var This = this;
              _.forEach(this.variants, function(variant){
                if(variant.id == This.itemable_id){
                  if(This.is_variant_package){
                    line_item.new_variant = variant
                  }else{
                    line_item.name = variant.name;
                    line_item.price = variant.price;
                    line_item.original_price = variant.original_price
                    line_item.itemable_id = variant.id
                    line_item.new_itemable_id = variant.id
                  }
                }
              })
            }
            callback(line_item)
          }
          this.close();
        }else{
          var errors = []
          var quantity = Number(this.quantity);
          if(typeof quantity != "number"){
            errors.push('请输入数字');
          }else if(quantity<=0){
            errors.push('数量必须大于0');
          }

          if(quantity % 1 != 0 && !this.is_variant_package){
            errors.push('请输入整数');
          }
          $rootScope.alert(errors)
        }
      },
      change_variant: function(variant){
        this.itemable_id = variant.id
        this.focus_input();
      }
    }
    $rootScope.edit_line_item_modal.init();
  }
  return {
    action: action
  }


}])
