module Ddt
  class BillTemplateSetting < Ddt::Base
    BillTemplate::Order::Base
    BillTemplate::Queue::Base
    include BelongsToBranch
    serialize :templates, Hash
    replicated_model


    def set_enable
      self.enable = true
      set_default_template
      save
    end

    def self.all_templates
      [
        :order_product_bill_template,
        :order_consume_bill_template,
        :order_append_product_bill_template,
        :order_bill_template,
        :order_short_bill_template,
        :order_one_by_one_bill_template,
        :order_per_product_bill_template,
        :order_label_bill_template,
        :order_append_bill_template,
        :order_append_one_by_one_bill_template,
        :order_append_per_product_bill_template,
        :order_subtract_bill_template,
        :order_subtract_one_by_one_bill_template,
        :order_subtract_per_product_bill_template,
        :order_hasten_bill_template,
        :order_hasten_item_bill_template,
        :order_reprint_bill_template,
        :queue_enqueueing_bill_template,
        :queue_pre_order_bill_template,
        :shift_bill_template,
        :shift_recharge_bill_template,
        :shifts_by_shift_template,
        :shifts_by_time_template,
      ]
    end

    self.all_templates.each do |template|
      define_method template do
        default_template = ""
        template.to_s.scan(/^([^_]*)_(.*)_template$/) do |namespace, name|
          default_template = BillTemplate.const_get(namespace.camelize).const_get(name.camelize).default_template
        end
        if self.enable? && self.shop.feature_modules_configs.available.enabled.where(feature_module: "bill_template").present?
          self.templates.fetch(template, default_template)
        else
          default_template
        end
      end
      define_method "#{template}=" do |new_template|
        self.templates[template] = new_template
      end
    end

    def self.preview_bill_in_html(branch, template_name)
      bill = preview(branch, template_name)
      transform_bill_to_html(bill) if bill.present?
    end

    def self.transform_bill_to_html(bill)
      bill.gsub(/\n/m, "<br>")
          .gsub(/\s/m, "&nbsp;")
          .gsub(/<M>/m,   "<span class='template-m'>")
          .gsub(/<\/M>/m, "</span>")
          .gsub(/<B>/m,   "<span class='template-b'>")
          .gsub(/<\/B>/m, "</span>")
          .gsub(/<D>/m,   "<span class='template-d'>")
          .gsub(/<\/D>/m, "</span>")
          .gsub(/<C>/m,   "<span class='template-c'>")
          .gsub(/<\/C>/m, "</span>")
          .gsub(/<CM>/m,  "<span class='template-cm'>")
          .gsub(/<\/CM>/m,"</span>")
          .gsub(/<CB>/m,  "<span class='template-cb'>")
          .gsub(/<\/CB>/m,"</span>")
          .gsub(/<CD>/m,  "<span class='template-cd'>")
          .gsub(/<\/CD>/m,"</span>")
          .gsub(/<(PCN)>(.*?)<\/\1>/) do |match|
            pcn = $2
            "<img class='template-qrcode' src='http://open.weixin.qq.com/qr/code/?username=#{pcn}'/>"
          end
          .gsub(/<(QRI)>(.*?)<\/\1>/) do |match|
            url = $2
            "<img class='template-qrcode' src='#{url}'/>"
          end
    end

    def self.preview(branch, template_name)
      if all_templates.include?(template_name.to_sym)
        bill = ""
        template_name.to_s.scan(/^([^_]*)_(.*)_template$/) do |namespace, name|
          bill = BillTemplate.const_get(namespace.camelize).const_get(name.camelize).preview(branch)
        end
        bill
      end
    end

    def reset(template_name)
      if self.class.all_templates.include?(template_name.to_sym)
        template_name.to_s.scan(/^([^_]*)_(.*)_template$/) do |namespace, name|
          default_template = BillTemplate.const_get(namespace.camelize).const_get(name.camelize).default_template
          self.send("#{template_name}=", default_template)
          self.save
        end
      end
    end

    private
    def set_default_template
      self.class.all_templates.each do |template_name|
        template_name.to_s.scan(/^([^_]*)_(.*)_template$/) do |namespace, name|
          self.send("#{template_name}=", BillTemplate.const_get(namespace.camelize).const_get(name.camelize).default_template)
        end
      end
    end
  end
end
