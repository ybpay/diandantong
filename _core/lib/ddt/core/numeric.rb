class Numeric
  include FixedWidth

  def round_to_floor(ndigit = 0)
    ((self * (10 ** ndigit)).floor.to_f/(10 ** ndigit)).round(ndigit)
  end
end
