#encoding: utf-8
class String
  # 一个汉字等于两个英文字符来算
  def width
    self.split('').inject(0) {|sum, s| sum += (s.bytesize == 3 ? 2 : 1)}
  end

  def fixed_width(total_width, float: :left)
    n = total_width - self.width
    return self if n < 0
    return "#{' '* n}#{self}" if float.to_sym == :right
    "#{self}#{' '* n}"
  end

end
