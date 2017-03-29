module Ddt
  class ItemNote < Ddt::Base
    include BelongsToBranchWithTouch
    include Ddt::HasManyTags
    include ListScope
    acts_as_list scope: [:shop_id]
    default_scope ->{list_order}
    replicated_model

    has_and_belongs_to_many :products, join_table: 'ddt_item_notes_products', class_name: 'Ddt::Product'
    ids_string_for :products

    validates :name, presence: true

    def select_json
      {id: id, name: name}
    end
  end
end
