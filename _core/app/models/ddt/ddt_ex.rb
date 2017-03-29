module Ddt
  class DdtEx < Ddt::Base
    self.abstract_class = true
    octopus_establish_connection "impression_#{Rails.env}".to_sym
    # establish_connection "impression_#{Rails.env}".to_sym
  end
end