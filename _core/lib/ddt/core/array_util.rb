module Ddt
  module ArrayUtil


    def delete_elements(eles)
      eles.each do |el|
        idx = self.index(el)
        self.delete_at(idx) if idx != nil
      end
    end

    def include_array?(arr)
      other = arr.dup
      each{|e| if index = other.index(e) then other.delete_at(index) end}
      other.empty?
    end

  end
end
