module Ddt
  class ItemNoteTag < Ddt::Tag

    has_many :item_notes_tags, class_name: 'Ddt::ItemNotesTag', foreign_key: :tag_id,  dependent: :destroy
    has_many :item_notes, through: :item_notes_tags, class_name: 'Ddt::ItemNote'
  end
end
