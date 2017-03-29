# encoding : utf-8
class DateTimeInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options)
    case input_type
    when :datetime
      pickDate = true
      pickTime = true
      format = 'YYYY-MM-DD HH:mm:ss'
      ruby_format = "%Y-%m-%d %H:%M:%S"
      group_class = "input-large"
    when :date
      pickDate = true
      pickTime = false
      format = 'YYYY-MM-DD'
      ruby_format = "%Y-%m-%d"
      group_class = "input-medium"
    when :time
      pickDate = false
      pickTime = true
      format = 'HH:mm'
      ruby_format = "%H:%M"
      group_class = "input-medium"
    end

    input_html_options[:onfocus] = "if(!$(this).data('DateTimePicker')){$(this).datetimepicker({pickDate:#{!!pickDate},pickTime:#{!!pickTime}, format:'#{format}'});$(this).data('DateTimePicker').show(); }"
    input_html_options[:class] ||= []
    input_html_options[:class] << "form-control"
    input_html_options[:value] ||= object.send(attribute_name) if object.present?
    input_html_options[:value] = input_html_options[:value].try(:strftime, ruby_format)
    out = ""
    out << template.content_tag(:div, :class => "input-group #{group_class}") do
      @builder.text_field(attribute_name, input_html_options) +
      template.content_tag(:span, :class => 'input-group-addon') do
        template.content_tag(:span, :class => "fa #{pickDate ? 'fa-calendar' : 'fa-clock-o'}") {}
      end
    end
  end
end
