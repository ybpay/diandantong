module Ddt
  module CommonApi
    module V1
      class StatisticsController < V1::BaseController

        before_action :set_statistic_type, only: [:result]
        before_action :check_statistic_valid, only: [:result]
        before_action :set_accessible_branches, only: [:result]

        #
        # satistics: [{:type, :name, :label, :permit_params}]
        #
        def index
          statistics = []
          [
            Ddt::BusinessStatistic,
            Ddt::CouponStatistic,
            Ddt::OrdersStatistic,
            Ddt::ProductStatistic,
            Ddt::TableStatistic,
            Ddt::UserStatistic,
            Ddt::WorkerStatistic
          ].each do |statistic_module|
            statistic_module::ALL.each do |klass|
              if klass.info[:expose_to_api]
                statistics << klass.info
              end
            end
          end
          render json: statistics
        end

        def last_shift
          @branch = current_account.managed_branches.find(params[:branch_id])
          @shift = @branch.current_shift
          @shift = @branch.shifts.order("created_at desc").first if @shift.blank?
          if @shift.present?
            @shift.update_amount
          else
            render json: { errors: "当前店铺没有开班" }, status: :bad_request
          end
        end

        def result
          # 报表改成异步，老板App无法使用, 提示升级
          render json: { errors: "老版本报表已下架，如需继续使用该功能，请升级版本。"}, status: :bad_request
          # klass = statistic_module.const_get(@name.classify)
          # params.permit(*klass.info[:permit_params])
          # @statistic = klass.new({
          #     shop: @current_shop,
          #     accessible_branches: @accessible_branches
          #     }.merge(params.symbolize_keys)
          #   )
          # respond_to do |format|
          #   format.json { render json: @statistic.to_hash }
          # end
        end

        private

        def statistic_module
          if 'orders' == @type
            type = 'Orders'
          else
            type = @type.classify
          end
          "Ddt::#{type}Statistic".constantize
        end

        def set_statistic_type
          @type = params[:type]
          @name = params[:name]
        end

        def check_statistic_valid
          hint = 'Oops!'
          if @type.blank? || @name.blank?
            render html: hint
            return
          end
          begin
            statistic_module
            klass = statistic_module.const_get @name.classify
            if !klass.info[:expose_to_api]
              render html: hint
            end
          rescue
            render html: hint
            return
          end
        end

        def set_accessible_branches
          @accessible_branches = current_account.managed_branches
        end

      end


    end
  end
end
