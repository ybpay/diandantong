
module Ddt
  module CommonApi
    module V1
      class ItemNotesController < V1::BaseController

        def index
          @item_notes = @current_branch.item_notes
          @tags = @current_branch.item_note_tags
          fresh_when([@item_notes, @tags])
        end

      end
    end
  end
end
