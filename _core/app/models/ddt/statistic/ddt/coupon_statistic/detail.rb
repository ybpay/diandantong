#encoding: utf-8
module Ddt
  module CouponStatistic
    class Detail < ::Ddt::CouponStatistic::Base
      attr_accessor :records
      include Ddt::CacheModel
      cache_model 'Ddt::Branch', with_deleted: true
      cache_model 'Ddt::AbstractCouponVersion', with_deleted: true

      def result
        @records ||= shop.base_coupons.where(applied_at: start_time..end_time, type: coupon_type).includes(:exchange_code).order(applied_at: :desc).paginate(page: page)
      end

      def filters
        [
          filter_start_time,
          filter_end_time
        ]
      end

      def title
        %W(操作人 操作人ID 优惠券名称 使用门店 面值 描述 使用时间 兑换码)
      end

      def body
        items = result
        content = []
        account_operator_ids = items.select{|i| i.operator_type == 'Ddt::Account'}.map(&:operator_id)
        accounts = Ddt::Account.with_deleted.find(account_operator_ids)
        items.each do |item|
          version = get_abstract_coupon_version(item.abstract_coupon_version_id)
          branch = get_branch(item.applied_in_branch_id)
          operator_type = ""
          operator_name = ""
          if item.operator_type.present?
            if item.operator_type == "Ddt::Account"
              operator_type = "商家账户"
              operator_name = accounts.find{|a| a.id == item.operator_id}.try(:name)
            elsif item.operator_type == "Ddt::BaseUser"
              operator_type = "用户"
              operator_name = item.operator_id
            end
          end
          scope_name = branch.nil? ? '平台' : branch.name
          content << [
            operator_type,
            operator_name,
            version.name,
            scope_name,
            version.norminal_value,
            version.description.truncate(20),
            item.applied_at.strftime("%F %T"),
            item.exchange_code.code
          ]
        end
        content
      end

    end
  end
end
