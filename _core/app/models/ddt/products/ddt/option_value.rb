# encoding:utf-8
module Ddt
  class OptionValue < Ddt::Base
    include Ddt::SoftDeletable
    include Ddt::ListScope
    include Ddt::BelongsToBranch

    # relations
    belongs_to :option_type, touch: true, class_name: 'Ddt::OptionType'
    has_and_belongs_to_many :variants, class_name: 'Ddt::Variant', join_table: 'ddt_option_values_variants'

    # validations
    validates_presence_of :name

    # scopes
    acts_as_list scope: [:option_type, :deleted_at]
    set_shop_and_branch_from :option_type

    # callbacks
    after_save :update_variants_cache_info, if: :name_changed?

    private
    def update_variants_cache_info
      self.variants.each(&:update_cache_info)
    end
  end
end