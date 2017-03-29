module Ddt
  module Commentable
    extend ActiveSupport::Concern
    included do
      if self == Ddt::Comment
        has_one :comment, ->{ includes(:owner, :commentable) }, as: :commentable, dependent: :destroy, class_name: 'Ddt::Comment'
      else
        has_many :comments, ->{ includes(:owner, :commentable, :comment) }, as: :commentable, dependent: :destroy, class_name: 'Ddt::Comment'
      end
      after_create :init_last_comment_at
      if self.table_exists? and self.column_names.include? "last_comment_at"
        scope :recent_commented, ->{ order(last_comment_at: :desc)}
      end
    end

    module ClassMethods
    end

    def commentable_label
      raise "#{self.class} : method not implement (commentable_label) "
    end

    def init_last_comment_at
      if self.has_attribute?(:last_comment_at)
        self.last_comment_at = self.created_at
        self.save
      end
    end

    def update_last_comment_at
      if self.has_attribute?(:last_comment_at) && self.created_at > 1.month.ago
        self.last_comment_at = Time.now
        self.save
      end
    end

  end
end