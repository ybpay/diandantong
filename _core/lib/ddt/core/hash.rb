class Hash
  def underscore_keys
    transform_keys{ |key| key.to_s.underscore.to_sym rescue key }
  end

  def deep_underscore_keys
    deep_transform_keys{ |key| key.to_s.underscore.to_sym rescue key }
  end

  def to_obj
    OpenStruct.new(self)
  end
end
