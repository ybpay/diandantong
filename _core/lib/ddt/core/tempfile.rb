class Tempfile
  def self.new_in_project(file_basename, extension, options={})
    self.new(["#{file_basename}_#{DateTime.now.to_i}_#{Random.new_seed}", extension], Rails.root.join('tmp'), options)
  end

  def destroy
    self.close
    self.unlink
  end
end
