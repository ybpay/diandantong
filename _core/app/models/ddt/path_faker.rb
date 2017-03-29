module Ddt
  class PathFaker < SimpleDelegator
    mattr_accessor :fake_klass, :fake_id

    def fake?
      __getobj__.nil?
    end

    def to_param
      super || @@fake_id.to_s
    end

    def self.model_name
      @@fake_klass.model_name
    end

    class Branch < self
      @@fake_klass, @@fake_id = Ddt::Branch, 'current'
    end

  end
end
