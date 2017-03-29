# hack for ruby-pinyin
# before hack
#    PinYin.abbr("美团79.9元抵扣券") => "79dikdkq"
# after hack
#    PinYin.abbr("美团79.9元抵扣券") => "mt799ydkq"
module PinYin
  module Backend
    class Simple
      def romanize(str, tone=nil, include_punctuations=false)
        res = []
        return res unless str && !str.empty?

        str.unpack('U*').each_with_index do |t,idx|
          code = sprintf('%x',t).upcase
          readings = codes[code]

          if readings
            if res.last == ""
              res.pop
              res << Value.new(format(readings, tone), false)
            else
              res << Value.new(format(readings, tone), false)
            end
          else
            val = [t].pack('U*')
            if val =~ /^[0-9a-zA-Z\s]*$/ # 复原，去除特殊字符,如全角符号等。
              if res.last && res.last.english?
                res.last << Value.new(val, true)
              elsif val != ' '
                res << Value.new(val, true)
              end
            elsif include_punctuations
              val = [Punctuation[code]].pack('H*') if Punctuation.include?(code)
              (res.last ? res.last : res) << Value.new(val, false)
            else
              res << Value.new("", true) unless res.last == ""
            end
          end
        end
        res.map {|phrase| phrase.split(/\s+/)}.flatten
      end
    end
  end
end