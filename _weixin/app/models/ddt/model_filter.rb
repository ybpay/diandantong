#encoding: utf-8
module Ddt
  class ModelFilter
    attr_accessor :op # ransack 算子
    attr_accessor :label # 显示名称
    attr_accessor :value # 默认值
    attr_accessor :collection # 可选集合或子过滤器
    attr_accessor :allow_default # 是否允许默认值

    def initialize(map)
      map.each do |k,v|
        method = "#{k}="
        self.send(method, v) if self.respond_to?(method)
      end
      if block_given?
        collection = yield(self)
        if collection.nil? or collection.empty?
          remove_instance_variable(:@collection) if instance_variable_defined?(:@collection)
          remove_instance_variable(:@allow_default) if instance_variable_defined?(:@allow_default)
        else
          self.collection = collection
        end
      end
    end

  end
end