#encdoing: utf-8
module Ddt
  module UserStatistic
    class UserAccess < ::Ddt::UserStatistic::Base
      attr_accessor :access_from, :ndays
      hash_attrs({
          访问来源: :access_form,
          天数: :ndays
      })

      def self.class_info
        {
          name: 'user_access',
          paginate: false,
          permit_params: [:start_time, :end_time, :branch_id, :access_from],
          default_params: today,
          label: '访问统计',
          expose_to_api: true
        }
      end

      def initialize(options={})
        super
        @access_from = options[:access_from] if options[:access_from].present?
        @ndays = Ddt::TimeUtil.days_between(start_time, end_time)
      end

      def result
        impressionable_type = @branch_id.present? ? "Ddt::Branch" : "Ddt::Shop"
        impressionable_id = @branch_id.present? ? @branch_id : shop.id
        message = access_from.blank?  ? "%wechat%" : "%#{access_from}%"
        Ddt::BaseUser.find_by_sql(["
          SELECT count(*) AS sum_of_count FROM impressions
          WHERE created_at between ? and ?
          AND impressionable_type = ?
          AND impressionable_id = ?
          AND message like ?
          ", start_time, end_time, impressionable_type, impressionable_id, message])
      end
      cache_result

      def filters
        [
          filter_branch(support_all: false),
          {name: 'access_from', type: 'collection', collection: [["来自微信", "wechat"], ["来自网站", "web"], ["来自朋友圈分享", "friendcircle"]], prompt: "选择来源", include_blank: false},
          filter_start_time,
          filter_end_time
        ]
      end

      def title
        %W[访问数量 日均].unshift("")
      end

      def body
        items = result
        content = []
        items.each do |item|
          content << [
            access_from_name,
            item.sum_of_count,
            item.sum_of_count / ndays
          ]
        end
        content
      end

      def access_from_name
        access_from ||= "wechat"
        {
          wechat: "来自微信",
          friendcircle: "来自朋友圈"
        }[access_from.to_sym]
      end

    end
  end
end
