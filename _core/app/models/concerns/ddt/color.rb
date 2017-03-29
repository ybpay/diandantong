module Ddt
  module Color
    extend ActiveSupport::Concern

    RED    = '#f34b3f'
    GREEN  = '#28a267'
    BLUE   = '#34afbe'
    ORANGE = '#FFA500'
    BLACK  = '#959595'

    included do
      [:red, :green, :blue, :orange, :black].each do |color|
        define_method color do
          self.class.const_get(color.to_s.upcase)
        end
      end
    end

  end
end
