module Ddt
  class Image < Ddt::Asset
    validates :attachment, :file_size => {
      :maximum => 0.5.megabytes.to_i
    }, presence: true
  end
end