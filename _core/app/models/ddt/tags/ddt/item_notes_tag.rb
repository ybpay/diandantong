module Ddt
  class ItemNotesTag < Ddt::Base
    belongs_to :item_note, class_name: 'Ddt::ItemNote', touch: true
    belongs_to :tag, class_name: 'Ddt::ItemNoteTag', counter_cache: :count
  end
end
