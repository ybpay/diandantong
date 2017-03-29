# encoding : utf-8
class ImagePreviewInput < SimpleForm::Inputs::FileInput
  def input(wrapper_options)
    # :preview_version is a custom attribute from :input_html hash, so you can pick custom sizes

    version = input_html_options.delete(:preview_version)
    input_html_options[:onchange] = "App.imagePreview(this);"
    out = ""

    out << template.content_tag(:div, :class => "form-control") do
      @builder.file_field(attribute_name, input_html_options) +
      @builder.hidden_field("#{attribute_name}_cache", input_html_options)
    end
    id = "#{@builder.object_name.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")}#{"_#{@builder.index}" if @builder.index.present?}_#{attribute_name}"
    image_url = object.send(attribute_name).tap {|o| break o.send(version) if version}.send(:url)
    image_tag = template.image_tag(image_url, :id => "#{id}_preview", :class => "#{version}")
    out << template.link_to(image_tag, "#", :title => "点击选择图片", :onclick => "$('##{id}').click();return false;")
    out.html_safe
  end
end