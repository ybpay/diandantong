module Ddt
  module ApplicableCouponVersion
    extend ActiveSupport::Concern
    included do
      validates :norminal_value, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 99990000.0}
    end

    module ClassMethods
    end
  end
end
