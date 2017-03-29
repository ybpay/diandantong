#encoding: utf-8
module Ddt
  module UserStatistic
    class Base < ::Ddt::StatisticBase
      include Ddt::StatisticHelper

      attr_accessor :branch, :branch_id, :start_time, :end_time, :access_from
      hash_attrs({
          门店: :branch_id,
          开始时间: :start_time,
          结束时间: :end_time,
          访问来源: :access_from
       })

      def initialize(options={})
        super
        @branch_id = options[:branch_id]
        if options[:branch_id].present? && options[:branch_id].to_i!= ALL_BRANCH
          @branch = Ddt::Branch.find(options[:branch_id])
        end
        @start_time, @end_time = options[:start_time], options[:end_time]
      end

      def branches
        branch.present? ? [branch] : shop.branches
      end

      def filter_vip_no
        {name: 'vip_no', type: 'string', placeholder: '会员编号'}
      end

      def filter_vip_phone
        {name: 'vip_phone', type: 'string', placeholder: '会员手机号'}
      end

      def set_query_params
        @vip_id_params = {}
        if @vip_no.present? || @vip_phone.present?
          q = {}
          q[:vip_no_eq] = @vip_no if @vip_no.present?
          q[:phone_eq] = @vip_phone if @vip_phone.present?
          @vip_info_ids = shop.vip_infos.ransack(q).result.map(&:id)
          @vip_id_params = {owner_type: 'Ddt::VipInfo', owner_id: @vip_info_ids}
        end
        @branch_params = {}
        if one_branch?
          @branch_params = {branch_id: branch_id}
        end
      end

    end
  end
end
