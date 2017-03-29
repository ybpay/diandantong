# encoding: utf-8
module Ddt
  module Backend
    module CommentsHelper
      def reply_detail(comment)
        reply_comment = comment.comment
        return "未回复" if reply_comment == nil
        return content_tag(:strong, "#{reply_comment.owner.comment_owner_label}: ") + reply_comment.content
      end

      def state_label_of_comment(comment)
        class_name = "label label-info"  if comment.state == 'pending'
        class_name = "label label-success" if comment.state == 'published'
        class_name = "label label-danger" if comment.state == 'closed'
        label_tag :state, comment.state_name, class: class_name
      end

      def reply_btn(record_or_array, options={})
        options[:url] = polymorphic_path([:reply, :backend, @current_shop, @current_branch].push(record_or_array).flatten , options[:url_options] || {})
        base_reply_btn(options)
      end

      def base_reply_btn(options={})
        options[:title] ||= '回复'
        options[:btn_size] ||= 'btn-xs'
        options[:remote] ||= false
        btn_class = options[:no_btn_class] ? '' : "btn #{options[:btn_size]} btn-info"
        link_to tag(:icon, :class => "fa fa-reply #{options[:icon_class]}"), options[:url], :class => [btn_class, options[:class]], :remote => options[:remote], :'data-rel' => "tooltip", :title => options[:title]
      end
    end
  end
end