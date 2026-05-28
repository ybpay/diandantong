module Ddt
  module BelongsToBranchWithTouch
    extend ActiveSupport::Concern
    included do
      belongs_to :shop, class_name: 'Ddt::Shop'
      belongs_to :branch, -> { with_discarded }, class_name: 'Ddt::Branch', touch: true

      # def shop
      #   TCC.fetch("shop.#{self.shop_id}") {super}
      # end

      # def branch
      #   TCC.fetch("branch.#{self.branch_id}") {super}
      # end

      if Rails.env.test?
        validates_presence_of :branch_id
      else
        validates_presence_of :branch
      end
      validates_presence_of :shop_id, if: Proc.new {self.has_attribute?(:shop_id)}
      set_shop_from :branch

      has_many :zones, class_name: 'Ddt::Zone', through: :branch
      scope :in_zone, ->(zone_id) {
        zone = Zone.find(zone_id)
        incZones = Zone.of_ancestor(zone)
        joins(:zones).where(:ddt_zones => { id:incZones.map(&:id)}).uniq
      }

    end

    module ClassMethods
    end

  end
end