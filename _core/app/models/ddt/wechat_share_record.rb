#encoding: utf-8
module Ddt
  class WechatShareRecord < Ddt::Base

    acts_as_paranoid
    include BelongsToShop
    belongs_to :user
    acts_as_type :share_type, %W[appmessage timeline weibo], %W[分享给朋友 分享到朋友圈 分享到微博]
    has_many :wechat_view_records, dependent: :destroy, class_name: 'Ddt::WechatViewRecord'
    has_many :viewed_users, class_name: 'Ddt::User', through: :wechat_view_records
    scope :of_verified, -> {where(:verified => true)}
    default_scope -> {order("created_at DESC")}
    validates_presence_of :trigger_timestamp, on: :create

    before_save :save_page_identifier


    private

    def save_page_identifier
      if self.link.present?
        self.page_identifier = Ddt::UrlUtil.get_query(self.link, "_ng_path")
      end
    end
  end
end
