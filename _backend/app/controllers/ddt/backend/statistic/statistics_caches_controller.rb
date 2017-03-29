#encoding: utf-8
module Ddt
  module Backend
    module Statistic
      class StatisticsCachesController < Backend::BaseController

        check_permission :shop, :statistic, :statistics_cache
        before_action :set_statistics_cache, only: [:destroy, :refresh]

        def index
          @q = @current_shop.statistics_caches.order(created_at: :desc).ransack(params[:q])
          @statistics_caches = @q.result.paginate(page: params[:page])
        end

        def destroy
          if @statistics_cache.destroy
            redirect_to backend_shop_statistics_caches_url(@current_shop), notice: "#{t('activerecord.models.ddt/statistics_cache')} 删除成功."
          else
            flash[:error] = @statistics_cache.errors.full_messages.join('<br/>')
            redirect_to backend_shop_statistics_caches_url(@current_shop)
          end
        end

        def refresh
          url = @statistics_cache.url
          @statistics_cache.destroy
          redirect_to url
        end

        def clear
          @current_shop.statistics_caches.delete_all
          flash[:alert] = '清除成功'
          redirect_to backend_shop_statistics_caches_url(@current_shop)
        end

        private
        def set_statistics_cache
          @statistics_cache = @current_shop.statistics_caches.find(params[:id] || params[:statistics_cach_id])
        end

      end
    end
  end
end
