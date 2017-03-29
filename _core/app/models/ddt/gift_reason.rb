module Ddt
  class GiftReason < Ddt::Base
    include ListScope
    include BelongsToShopWithTouch
    replicated_model

    validates_presence_of :name
    acts_as_list scope: [:shop_id]
    default_scope ->{list_order}
  end
end