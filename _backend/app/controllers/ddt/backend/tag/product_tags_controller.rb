module Ddt
  class Backend::Tag::ProductTagsController < Backend::TagsController

    private
    def tag_params
      params.require(:product_tag).permit(:name, :color)
    end
  end
end
