module Ddt
  module Backend
    module Statistic
      class BaseController < Backend::BaseController
        layout 'ddt/layouts/backend/statistic/base'
        before_action :set_statistic_params
        before_action :set_accessible_branches

        def self.init_statistics(statistics=[])
          statistics = statistics.map{|s| OpenStruct.new(s)}
          around_action :select_statistics_db, only: statistics.map(&:name).map(&:to_sym)
          statistics.each do |s|
            define_method s.name do

              @statistics = self.class::STATISTICS
              @statistic_name = statistic_name
              statistic_params.permit(*s.permit_params)
              rand_hash = params['rand_hash'] # statistics random hash

              # 页面请求类型:
              # * form: 仅返回查询表单
              # * result: 期望返回结果
              # * state: 返回查询状态
              @pr_type = params['pr_type']
              @pr_type = request.url.include?('?') ? 'result' : 'form' if @pr_type.blank?

              klass = statistic_module.const_get(s.name.classify)
              page_field = statistic_params.delete('page')
              @statistic = klass.new({
                                         statistic_name: statistic_name,
                                         request_path: request.path,
                                         request_url: request.original_fullpath,
                                         shop: @current_shop,
                                         accessible_branches: @accessible_branches,
                                         page: params[:page] || page_field,
                                         rand_hash: rand_hash,
                                         pr_type: @pr_type,
                                         statistics_operator_id: current_account.id
                                     }.merge(statistic_params.symbolize_keys)
              )

              if @pr_type == 'form'
                render_result_view(s)
              else # result
                cache = @statistic.cache_record
                if cache.present?
                  if cache.is_completed?
                    render_result_view(s)
                  else
                    render_query_view(s)
                  end
                else
                  @statistic.submit_async_statistics
                  render_query_view(s)
                end
              end
            end
          end
        end

        def render_query_view(s)
          respond_to do |format|
            format.html {
              render 'async_getting_result'
            }
            format.json {
              render json: @statistic.cache_state
            }
          end
        end

        def render_result_view(s)
          respond_to do |format|
            format.html {
              if @pr_type == 'form'
                if s.render_view
                  # default view
                else
                  render 'common_view'
                end
              else

                if s.render_view
                  @result = @statistic.fetch_statistics_result if @pr_type == 'result'
                else
                  @statistic.fetch_statistics_result
                  render 'common_view'
                end
              end
            }
            format.json {
              render json: @statistic.cache_state
            }
            format.csv {
              redirect_to @statistic.cache_record.csv.url
            }
            format.xls {
              redirect_to @statistic.cache_record.xls.url
            }
          end
        end

        def select_statistics_db(&block)
          # 此方式使非主从分享的模型都往查询库查询
          block.call
        end

        def statistic_name
          controller_name.singularize.to_sym
        end

        def statistic_module
          "Ddt::#{controller_name.classify}".constantize
        end

        private
        def statistic_params
          params.require(statistic_name)
        end

        def set_statistic_params
          params[statistic_name] ||= {}
          params[statistic_name][:start_time] = Time.now.beginning_of_day   if params[statistic_name][:start_time].blank?
          params[statistic_name][:end_time] = Time.now.end_of_day           if params[statistic_name][:end_time].blank?
        end

        def set_accessible_branches
          @accessible_branches = managed_branches
        end

      end
    end
  end
end
