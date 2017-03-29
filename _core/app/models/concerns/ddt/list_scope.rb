module Ddt
  module ListScope
    extend ActiveSupport::Concern
    included do
      scope :list_order, ->{ order(position: :asc)}
    end

    def change_position(position_param)
      if position_param.present?
        position = Integer(position_param) rescue position_param
        if position.is_a? Fixnum
          self.insert_at(position)
        elsif %W[move_to_top move_to_bottom].include? position
          self.send(position)
        end
      end
    end
  end
end