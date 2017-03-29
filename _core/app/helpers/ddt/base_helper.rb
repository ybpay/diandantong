#encoding: utf-8
module Ddt
  module BaseHelper
    def find_or_set_title
      if @current_shop.present? and @current_shop.agent.present? and @current_shop.agent.brand.present?
        @current_shop.agent.brand
      elsif request.host != "mall.diandantong.com"
        "云餐厅"
      else
        title = SiteConfig.find_by_key('title')
        if title.nil?
          title = SiteConfig.create!(
            :key => 'title',
            :display_name => '站点名称',
            :value_type => 'string',
            :value_s => '点单通'
          )
        end
        title.value_s
      end
    end

    def is_ddt_domain
      [Ddt::Host::DEPLOY, Ddt::Host::LOCAL].include? request.host
    end

    def custom_domain_shop
      Ddt::Shop.find_by(custom_domain: request.host) unless is_ddt_domain
    end


    def slogan_word
      "智慧餐饮"
    end



    def bootstrap_flash
      alert_types = [:error, :info, :success, :warning]
      flash_messages = []
      flash.each do |type, message|
        # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
        next if message.blank?

        type = type.to_sym
        type = :success if type.to_s == :notice.to_s
        type = :info  if type.to_s == :alert.to_s
        type = :error  if type.to_s == :error.to_s
        next unless alert_types.include?(type)

        Array(message).each do |msg|
          # text = content_tag(:div,
          #                    content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
          #                    msg, :class => "alert fade in alert-#{type}", data: {dismiss: "alert"})
          text = javascript_tag("toastr.#{type}('#{msg}')")
          flash_messages << text if msg
        end
      end
      flash_messages.join("\n").html_safe
    end


    def error_message_in_html(m)
      html = ""
      html += "<p class='error_title'>您提交的信息有如下错误:</p>"
      html += "<ul>"
      m.errors.full_messages.each do |msg|
        html += "<li>#{msg}</li>"
      end
      html += "</ul>"
    end
  end
end
