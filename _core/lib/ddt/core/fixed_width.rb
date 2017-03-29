module FixedWidth
  def fixed_width(total_width, float: :left)
    self.to_s.fixed_width(total_width, float: float)
  end
end
