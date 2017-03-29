module Ddt
  class FileCompress

    def initialize(zip_file_path)
      @zipfile = Zip::File.open(zip_file_path, Zip::File::CREATE)
    end

    def compress_file(file_path)
      @zipfile.add(get_filename(file_path), file_path)
      @zipfile.commit if @zipfile.commit_required?
    end

    def finish
      @zipfile.close
    end

    private

    def get_filename(path)
      path.split("/").pop()
    end

  end
end