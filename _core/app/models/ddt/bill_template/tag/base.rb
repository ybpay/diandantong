module Ddt
  module BillTemplate
    module Tag
      class Base
        MAX_INT = 100
        attr_accessor :body, :attrs, :content
        def initialize(body:, attrs:, content:)
          self.body = body
          self.attrs = attrs
          self.content = content
          if lstrip
            self.content = self.content.lstrip
          end
          if rstrip
            self.content = self.content.rstrip
          end
        end

        def render_empty
          ' ' * width
        end

        def self.tag_attr(name, type, options={})
          define_method name do
            vname = "@#{name}"
            if instance_variable_defined?(vname)
              instance_variable_get(vname)
            else
              value = self.attrs[name]
              if value.present?
                case type.to_sym
                when :string
                  if value =~ /\A['"](.+)['"]\Z/
                    value = $1
                  end
                when :int
                  value = value.to_i
                  value = 0 if value < 0
                  value = MAX_INT if value > MAX_INT
                when :boolean
                  value = (value == 'true')
                end
              else
                value = options[:default]
              end
              instance_variable_set(vname, value)
            end
          end
        end
        tag_attr :lstrip, :boolean, default: true
        tag_attr :rstrip, :boolean, default: true
      end
    end
  end
end