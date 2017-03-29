#encoding: utf-8
module SimpleForm
  class FormBuilder

    alias_method :original_button, :button
    def button(type, *args, &block)
      if :submit == type.to_sym
        options = args.extract_options!.dup
        options.merge!({data: {disable_with: '提交中'} })
        args << options
      end
      original_button(type, *args, &block)
    end

  end
end
