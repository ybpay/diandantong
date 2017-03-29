# encoding: utf-8
module Ddt
  module Backend
    module ViewFormatHelper

      #
      # 切换当前展示对象
      #
      def show_for(object, klass = nil)
        klass = object.class unless klass.present?
        if block_given?
          preserve_for do
            show_for(object, klass)
            yield object, klass
          end
        else
          @_model_object = object
          @_model_class = klass
        end
      end

      def show_simple_attr(*names)
        options = extract_options names
        names.each do |name|
          concat(content_tag(:p) do
            concat(content_tag(:b) do
              concat "#{@_model_class.send(:human_attribute_name, name)}: "
              if block_given?
                if @_model_object.respond_to? name
                  yield @_model_object.send(name), name
                else
                  yield nil, name
                end
              else
                concat @_model_object.send(name)
              end
            end)
          end)

          # haml_tag :p do
          #   haml_tag :b do
          #     haml_concat "#{@_model_class.send(:human_attribute_name, name)}:"
          #     if block_given?
          #       if @_model_object.respond_to? name
          #         yield @_model_object.send(name), name
          #       else
          #         yield nil, name
          #       end
          #     else
          #       haml_concat @_model_object.send(name)
          #     end
          #   end
          # end
        end
      end

      def attr_tab_head(*names)
        options = extract_options names
        options[:search] = options[:search] || @q
        names.each do |name|
          concat(content_tag(:th) do
            if options[:sort_link]
              concat sort_link(options[:search], name, @_model_class.human_attribute_name(name))
            else
              concat @_model_class.human_attribute_name(name)
            end
          end)
        end
      end

      def attr_tab_column(*names)
        options = extract_options names
        names.each do |name|
          concat(content_tag(:td) do
            concat @_model_object.send(name)
          end)
        end
      end

      def simple_show_link(record_or_array)
        link_to t('Show'), polymorphic_path([:backend, @current_shop].push(record_or_array).flatten), :class => 'btn btn-default btn-sm'
      end

      def simple_edit_link(record_or_array)
        link_to t('Edit'), polymorphic_path([:backend, @current_shop].push(record_or_array).flatten, action: :edit), :class => 'btn btn-primary btn-sm'
      end

      def simple_back_link(record_or_array)
        link_to t('Back'), polymorphic_path([:backend, @current_shop].push(record_or_array).flatten), :class => 'btn btn-default btn-sm'
      end

      def simple_info_btn(record_or_array, options = {})
        options[:url] ||= polymorphic_path([:backend, @current_shop, record_or_array])
        base_info_btn options
      end

      def simple_edit_btn(record_or_array, options = {})
        options[:url] ||= polymorphic_path([:backend, @current_shop, record_or_array], action: :edit)
        base_edit_btn options
      end

      def simple_delete_btn(record_or_array, options = {})
        options[:url] ||= polymorphic_path([:backend, @current_shop, record_or_array])
        base_delete_btn options
      end

      private
      #
      # 保存当前正在显示的对象
      #
      def preserve_for
        @_model_stack = [] unless @_model_stack.present?

        if @_model_object.present? or @_model_class.present?
          @_model_stack.push [@_model_object, @_model_class]
          preserve = true
        else
          preserve = false
        end

        if block_given?
          yield
          @_model_object, @_model_class = @_model_stack.pop if preserve
        end
      end

      def extract_options(labels)
        if labels.last.is_a? Hash
          labels.pop
        else
          {}
        end
      end

    end
  end
end



