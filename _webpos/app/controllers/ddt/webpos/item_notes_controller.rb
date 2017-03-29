module Ddt
  module Webpos
    class ItemNotesController < Webpos::BaseController

      def index
        @item_notes = @current_branch.item_notes
        @tags = @current_branch.item_note_tags
        fresh_when([@item_notes, @tags])
      end
    end
  end
end
