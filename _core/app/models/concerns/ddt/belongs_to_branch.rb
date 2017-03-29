module Ddt
  module BelongsToBranch
    extend ActiveSupport::Concern

    module ClassMethods
      attr_reader :skip_validate_branch
      def skip_validate_branch?
        @skip_validate_branch
      end
      private
      def skip_validate_branch
        @skip_validate_branch = true
      end
    end

    included do
      belongs_to :shop, class_name: 'Ddt::Shop'
      belongs_to :branch, -> { with_deleted }, class_name: 'Ddt::Branch'
      delegate :name, to: :branch, prefix: true

      def shop
        TCC.fetch("shop.#{self.shop_id}") {super}
      end

      def branch
        TCC.fetch("branch.#{self.branch_id}") {super}
      end

      validates_presence_of :branch_id, unless: Proc.new{self.class.skip_validate_branch?}
      validates_presence_of :shop_id, if: Proc.new {self.has_attribute?(:shop_id)}
      set_shop_from :branch

      has_many :zones, class_name: 'Ddt::Zone', through: :branch
      scope :in_zone, ->(zone_id) {
        zone = Zone.find(zone_id)
        incZones = Zone.of_ancestor(zone)
        joins(:zones).where(:ddt_zones => { id:incZones.map(&:id)}).uniq
      }

    end

  end
end