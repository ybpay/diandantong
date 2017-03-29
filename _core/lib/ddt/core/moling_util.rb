module Ddt
  module MolingUtil

    class << self
      def erase(num, ndigits=0)
        ndigits = Integer(ndigits)
        return num if ![-1,0,1].include?(ndigits)
        (num * 10**ndigits).floor * (10**(-ndigits)).to_f
      end

      def round(num, ndigits=0)
        ndigits = Integer(ndigits)
        return num if ![-1,0,1,2].include?(ndigits)
        num.round(ndigits)
      end
    end

  end
end
