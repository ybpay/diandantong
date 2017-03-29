#encoding:utf-8
module Ddt
  module Backend
    module BranchesHelper

      def fake_branch
        @fake_branch ||= Ddt::PathFaker::Branch.new(@current_branch)
      end

      def fake_branch_link(name, array)
        url = polymorphic_path(array)
        if url.include? Ddt::PathFaker::Branch.fake_id
          link_to name, "javascript: alert_branch_choose('#{url}')"
        else
          link_to name, url
        end
      end

      def new_btn(record_or_array, options={})
        options[:url] = polymorphic_path([:new, :backend, @current_shop, @current_branch].push(record_or_array).flatten , options[:url_options] || {})
        base_new_btn(options)
      end

      def info_btn(record_or_array, options={})
        options[:url] = polymorphic_path([:backend, @current_shop, @current_branch].push(record_or_array).flatten , options[:url_options] || {})
        base_info_btn(options)
      end

      def edit_btn(record_or_array, options={})
        options[:url] = polymorphic_path([:edit, :backend, @current_shop, @current_branch].push(record_or_array).flatten , options[:url_options] || {})
        base_edit_btn(options)
      end

      def delete_btn(record_or_array, options={})
        options[:url] = polymorphic_path([:backend, @current_shop, @current_branch].push(record_or_array).flatten , options[:url_options] || {})
        base_delete_btn(options)
      end

      def base_new_btn(options={})
        options[:title] ||= '新建'
        options[:remote] ||= false
        btn_class = options[:no_btn_class] ? '' : "btn #{options[:btn_size]} btn-primary"
        link_to options[:url], :class => [btn_class, options[:class]], :remote => options[:remote], :'data-rel' => "tooltip", :title => options[:title] do
          "<i class='fa fa-plus #{options[:icon_class]}'></i> #{options[:label]}".html_safe
        end
      end

      def base_info_btn(options={})
        options[:title] ||= '详情'
        options[:show_label] ||= false
        options[:remote] ||= false
        options[:method] ||= :get
        link_to "#{options[:title]}", options[:url],  :remote => options[:remote], :method => options[:method]
      end

      def base_edit_btn(options={})
        options[:title] ||= '编辑'
        options[:remote] ||= false
        link_to "#{options[:title]}", options[:url], :remote => options[:remote]
      end

      def base_delete_btn(options={})
        options[:title] ||= '删除'
        options[:remote] ||= false
        link_to "#{options[:title]}", options[:url], :'data-confirm' => "确定删除?", :method => :delete, :remote => options[:remote]
      end
    end
  end
end
