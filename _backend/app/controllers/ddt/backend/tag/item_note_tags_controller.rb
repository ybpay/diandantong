module Ddt
  class Backend::Tag::ItemNoteTagsController < Backend::TagsController

    private
    def tag_params
      params.require(:item_note_tag).permit(:name)
    end
  end
end
