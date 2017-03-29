# encoding: utf-8
module Ddt
  class Comment < Ddt::Base

    # relationships
    include Ddt::BelongsToBranchWithTouch
    include Ddt::Commentable
    belongs_to :commentable, polymorphic: true
    belongs_to :branch, class_name: 'Ddt::Branch', counter_cache: :comments_count
    belongs_to :owner, polymorphic: true
    belongs_to_order
    #validates_presence_of :user
    # validates_presence_of :commentable
    validates_presence_of :content
    scope :of_published, ->{where(state: :published)}
    default_scope { order('created_at DESC')}

    acts_as_type :state, [:pending, :published, :closed], %W[未处理 已显示 已屏蔽]

    ####callback
    before_create :set_publish
    after_save :calculate_rating, if: :state_changed?

    def commentable_label
      "回复： " + (owner.comment_owner_label rescue "")
    end

    def commentable
      if self.commentable_type = "Ddt::Order"
        @commentable ||= OrderService::Order::Base.find(self.commentable_id)
      else
        super
      end
    end

    private

    def calculate_rating
        average = self.branch.branch_comments(:reload).of_published.average(:rating)
        self.branch.update!(:rating => average)
    end

    def set_publish
      if branch
        self.state = (branch.auto_publish_comment ? :published : :pending)
      end
    end

  end
end
