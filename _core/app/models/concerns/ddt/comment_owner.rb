module Ddt
  module CommentOwner
    extend ActiveSupport::Concern
    included do
      has_many :comments, as: :owner, dependent: :destroy, class_name: 'Ddt::Comment'
    end

    module ClassMethods
    end

    def comment_owner_label
      raise "#{self.class}: method not implement(comment_owner_label)"
    end

  end
end