# encoding: utf-8
module Ddt
  class FormElement < Ddt::Base
    include Ddt::SoftDeletable

    serialize :support_order_types
    ### relationships
    belongs_to :branch, touch: true
    belongs_to :shop
    belongs_to :form_element
    has_many :form_elements, dependent: :destroy
    accepts_nested_attributes_for :form_elements, allow_destroy: true
    has_many :options, class_name: 'FormElementOption', foreign_key: :form_element_id

    ### scope
    scope :with_delivery,    -> { where(support_delivery: true)}
    scope :with_reservation, -> { where(support_reservation: true)}
    scope :with_eat_in_hall, -> { where(support_eat_in_hall: true)}
    scope :with_fastfood, -> {where(support_fastfood: true)}

    ### validations
    validates_presence_of :statement
    #validate :validate_support_order_types, unless: :is_form_element_option?

    def support_order_types
      types = []
      types << 'delivery' if support_delivery?
      types << 'eat_in_hall' if support_eat_in_hall?
      types << 'reservation' if support_reservation?
      types << 'fastfood' if support_fastfood?
      types
    end

    def get_support_order_type_names
      OrderService::Order::Base.types.select do |order_type|
        self.support_order_types.include?(order_type)
      end
    end

    def validate_support_order_types
      order_types = OrderService::Order::Base.types
      self.support_order_types.each do |support_order_type|
        unless order_types.include? support_order_type
          self.errors.add("support_order_types", "设置错误！")
        end
      end
    end

    def is_form_element_option?
      self.type.demodulize == "FormElementOption"
    end

    class << self
      def by_branch_with_options(branch)
        includes(:options).where("branch_id = ?", branch.id).
        where("form_element_id is null or form_element_id = 0").
        order("sequence")
      end

      def by_branches_with_options(branch_ids)
        includes(:options).where(:branch_id => branch_ids).
        where("form_element_id is null or form_element_id = 0").
        order("sequence")
      end
    end
  end
end
