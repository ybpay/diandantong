class StringIoUploadFile < StringIO
  attr_accessor :original_filename
  def initialize(filename, content, serialize = false)
    super(serialize ? Marshal::dump(content) : content)
    self.original_filename = filename.to_s.gsub('-', '_')
  end
end