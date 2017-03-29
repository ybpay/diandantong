#encoding: utf-8
module Ddt
  class Weixin::BranchesController < WeixinApplicationController
    include Weixin::ModelFilterPlugin

    def branch_sort_filter
      # q[s]=views_count+desc
      ModelFilter.new(
          op: "#{query_pname}[s]",
          label: '综合排序',
          value: '',
          allow_default: true
      ) do |f|
        [
            ModelFilter.new({
              op: "#{query_pname}[of_in_service]",
              label: '正在营业',
              value: true
            }),
            # 仅用作界面显示
            ModelFilter.new({
                                op: 'query[sort_by_distance]',
                                label: '距离优先',
                                value: true
                            }),
            ModelFilter.new({
                                op: f.op,
                                label: '预订优先',
                                value: 'use_reservation_setting desc'
                            }),
            # ModelFilter.new({
            #                     op: f.op,
            #                     label: '优惠优先',
            #                     value: ''
            #                 })
            ModelFilter.new({
                op: 'query[delivery_setting_support_delivery_if_amount_gt_eq]',
                label: '无起送金额',
                value: '0'
                            })
        ]
      end
    end

    def index
      if params[:query].present?
        if params[:query][:sort_by_distance]
          # 距离排序
          @branches = query do |query|
            query.by_distance(:origin => @current_user)
          end
        elsif params[:query][:s].present?
          # 如果有已经定义好的排序，则按定义好的进行
          @branches = query
        else
          # 非特殊排序，则用综合排序
          @branches = default_query
        end
      else
        # 无过滤条件，用综合排序
        @branches = default_query
      end
    end

    def show
      @branch = @current_shop.branches_include_abstract.find(params[:id])
      @form_elements = @branch.form_elements
    end

    private

    #
    # 查询门店，可传入 block 来增强查询条件
    #
    def query(options = {})
      options = {
          paginate: true
      }.merge(options)
      query = Ddt::Branch.where(shop: @current_shop).open_on_today.valid_now
                  .includes(:reservation_setting, :delivery_setting, :delivery_times)
      query = yield(query) if block_given?
      query = query.order(:position => :asc).ransack(params[:query]).result(distinct: true)
      query = query.paginate(:page => params[:page],:per_page => params[:per_page] || 8) if options[:paginate]
      query
    end

    #
    # 综合排序
    #   非营业中
    #     放最后，且按距离排序
    #   营业中
    #     500 米内按权重排序(position)，不分页，随第一页返回
    #     500 米外按距离排序，分页
    # 如果是距离排序
    #   直接按距离排
    #
    def default_query
      branches = []
      # 500 米内，按优先级排序，不分页
      if params[:page].blank? or params[:page].to_i == 1
        branches = query({paginate: false}) do |query|
          query.within(0.5, :origin => @current_user)
        end
      end
      # 500 米外，按距离排序，分页
      without_500m = query do |query|
        query.beyond(0.5, :origin => @current_user).by_distance(:origin => @current_user)
      end
      # 正在营业的 显示在前
      branches = branches.concat(without_500m)
      service_branches = branches.clone
      branches.each do |branch|
        if branch.is_in_service
          service_branches.delete(branch)
          service_branches.unshift(branch)
        end
      end
      service_branches
    end


  end
end
