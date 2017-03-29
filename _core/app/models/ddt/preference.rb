module Ddt
  class Preference < Ddt::Base
    serialize :value
    validates :key, presence: true
  end
end
