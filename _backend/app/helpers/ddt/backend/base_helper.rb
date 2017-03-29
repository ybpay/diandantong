#encoding: utf-8
module Ddt
  module Backend
    module BaseHelper

      def branch_link(branch, path_array)
        index = path_array.index(branch)
        path_array[index] = Ddt::PathFaker::Branch.new(branch)
        path = polymorphic_path(path_array)
        path.include?(Ddt::PathFaker::Branch.fake_id) ? "javascript: alert_branch_choose('#{path}')" : path
      end

      def render_sidebar
        Ddt::Backend::Sidebar.new(self,
          account: @current_account,
          current_shop: @current_shop,
          current_branch: @current_branch,
          ).render_result
      end

      def asset_root_url
        asset = Ddt::Host::ASSET
        asset.present? ? "#{asset}/" : root_url()
      end

      def module_name_to_module(module_name)
        @current_shop.send module_name
      end

      def wechat_enabled?
        @current_shop.nil?
      end

      def has_module?(key)
        @current_shop.has_module?(key)
      end

      def position_select_option(index_count)
        options = [["置顶", "move_to_top"]]
        (1..index_count).each do |index|
          options << ["第#{index}位", index]
        end
        options << ["埋底", "move_to_bottom"]
      end

      def change_position_form(url, all_item, item)
        form_tag url, :method => "PUT", remote: true, style: "display:inline-block;" do
          select_tag :position, options_for_select(position_select_option(all_item.count)), prompt: item.position, onchange: "$(this.form).submit();"
        end
      end

      def remote_select_form(url, name, all_type_hash, current_type )
        form_tag url, :method => "PUT", remote: true, style: "display:inline-block;" do
          select_tag name, options_for_select(all_type_hash.map{|obj| [obj[:name], obj[:value]]}, current_type), class: "form-control", onchange: "$(this.form).submit();"
        end
      end

      def qrcode_image_url(gonghao_open_id_or_username)
        "http://open.weixin.qq.com/qr/code/?username=#{gonghao_open_id_or_username}"
      end

      def active_if(*path)
        'active' if path.flatten.any?{|p| controller_path.include? p.to_s }
      end

      def enable_label(enable)
        if enable
          content_tag(:span, '启用', class: 'label label-success')
        else
          content_tag(:span, '禁用', class: 'label')
        end
      end

      #
      #
      #
      def side_menu_tag(name, href, active_condition, icon, options = {})
        if options[:permitted]
          content_tag(:li, class: ('active' if active_condition)) do
            content_tag(:a, href: href, target: (options[:target] if options[:target].present?)) do
              str = content_tag(:i, '', class: "fa #{icon} icon-") + name
              unless options[:permitted]
                str += content_tag(:span, class: 'badge badge-transparent', title: '无权操作') do
                  content_tag("i", '', class: 'fa fa-warning red bigger-130')
                end
              end
              if options[:expired].present?
                str += content_tag(:span, class: 'badge badge-transparent', title: options[:expired]) do
                  content_tag("i", '', class: 'fa fa-question red bigger-130')
                end
              end
              str << notice_tag(options[:number])
              str
            end
          end
        end
      end

      def menu_tag(name, href, icon, options={})
        content_tag(:li, class: 'sm-li', sm_permitted: options[:permitted], sm_module: options[:module], sm_if_module: options[:if_module],
                         sm_controllers: options[:controllers], sm_actions: options[:actions], sm_no_actions: options[:no_actions]) do
          content_tag(:a, href: href, target: (options[:target] if options[:target].present?)) do
            str = content_tag(:i, '', class: "fa #{icon} icon-") + name
            str << notice_tag(options[:number])
          end
        end
      end

      def menu_toggle(name, icon, options={})
        content_tag(:a, class: "dropdown-toggle", href: "#") do
          str = content_tag(:i, '', class: "fa #{icon} icon-")
          str << content_tag(:span, name, class: "nav-label")
          str << notice_tag(options[:number])
          str << content(:span, "", class: 'fa arrow')
          str.html_safe
        end
      end

      def notice_tag(number, color="success")
        if number.present? && number > 0
          return content_tag(:span, number.to_s, class: "badge badge-#{color}")
        end
        return ""
      end

      def preference_field_tag(name, value, options={})
        case options[:type]
        when :integer
          text_field_tag(name, value, preference_field_options(options))
        when :boolean
          hidden_field_tag(name, 0, id: "#{name}_hidden") +
          check_box_tag(name, 1, value, preference_field_options(options))
        when :string
          text_field_tag(name, value, preference_field_options(options))
        when :password
          password_field_tag(name, value, preference_field_options(options))
        when :text
          text_area_tag(name, value, preference_field_options(options))
        else
          text_field_tag(name, value, preference_field_options(options))
        end
      end

      def preference_field_for(form, field, options={})
        case options[:type]
        when :integer
          form.text_field(field, preference_field_options(options))
        when :boolean
          form.check_box(field, preference_field_options(options))
        when :string
          form.text_field(field, preference_field_options(options))
        when :password
          form.password_field(field, preference_field_options(options))
        when :text
          form.text_area(field, preference_field_options(options))
        else
          form.text_field(field, preference_field_options(options))
        end
      end

      def preference_field_options(options={})
        field_options = case options[:type]
        when :integer
          { :size => 10,
            :class => 'input_integer' }
        when :boolean
          {}
        when :string
          { :size => 10,
            :class => 'input_string fullwidth' }
        when :password
          { :size => 10,
            :class => 'password_string fullwidth' }
        when :text
          { :rows => 15,
            :cols => 85,
            :class => 'fullwidth' }
        else
          { :size => 10,
            :class => 'input_string fullwidth' }
        end

        field_options.merge!({
          :readonly => options[:readonly],
          :disabled => options[:disabled],
          :size     => options[:size]
        })
      end

      def data_head(model_class, options, *columns)
        content = []
        col_width_array = options['col-sm']
        columns.try(:each_with_index) do |column, index|
          class_string = col_width_array.present? ? "col-sm-#{col_width_array[index % col_width_array.length]}" : ''
          content.push(content_tag(:th, {class: class_string}) do
                         sort_link(@q, column, model_class.human_attribute_name(column))
                       end)
        end
        content.join("\n").html_safe
      end

      def data_columns(model_object, *columns)
        (columns.try(:collect) do |column|
            case column
              when Proc
                content = column.call(model_object)
              when Symbol
                content = model_object.send(column)
            end
            content_tag(:td, content)
        end).try(:join, "\n").try(:html_safe)
      end

      # 后台右上角个人中心链接地址，admin超级管理员账户没有所属的shop，对应地址为"#"
      def backend_personal_info_link
        if [current_account, @current_shop].all?(&:present?) && @current_shop == current_account.shop
          edit_backend_shop_account_path(@current_shop, current_account)
        else
          "#"
        end
      end

      def advanced_options
        content_tag :div, class: 'form-group advanced-options col-sm-12' do
          content = []
          content << content_tag(:a, "高级", class: 'btn-sm btn-warning advanced-options-open')
          content << content_tag(:div, class: 'advanced-options-content', style: 'display:none;') do
                      yield
                    end
          content << content_tag(:div, '', class: 'clearfix')
          content << content_tag(:a, "收起", class: 'btn-sm btn-warning advanced-options-close', style: 'display:none;')
          content.join().html_safe
        end
      end

      def no_record_hint(set, hint=nil)
        return "" if set.size > 0
        hint_msg = hint || "目前尚没有记录"
        return raw "<tr><td colspan='20' class='text-center'>#{hint_msg}</td></tr>"
      end

      def labels(names, color: 'primary')
        class_name = "label label-#{color}"
        html = ""
        names.each do |name|
          html += "<span class='#{class_name}'>#{name}</span> "
        end
        raw html
      end

    end
  end
end
