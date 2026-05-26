module Ddt
  class Zone < Ddt::Base
    include BelongsToShop

    belongs_to :parent_zone, class_name: 'Ddt::Zone', foreign_key: :parent_zone_id, inverse_of: :zones
    has_and_belongs_to_many :branches, class_name: 'Ddt::Branch'
    ids_string_for :branches
    has_many :zones, dependent: :destroy, foreign_key: :parent_zone_id, inverse_of: :parent_zone
    set_shop_from :parent_zone
    scope :of_root, ->{ where(:parent_zone_id=>nil) }
    validates :name, presence: true, :uniqueness => {scope: [:shop_id, :parent_zone_id]}
    scope :of_ancestor, ->(ancestor) do
      idSet = []
      allSet = [ancestor]
      newSet = [ancestor]
      until (newSet.empty?) do
        idSet = newSet.map {|z| z.id}
        newSet = where(:parent_zone_id => idSet)
        allSet += newSet
      end
      allSet
    end

    def select_json
      { id: self.id, name: self.name}
    end

    def name_with_parent
      self.parent_zone.present? ? "#{self.parent_zone.name_with_parent}-#{self.name}" : name
    end
  end
end