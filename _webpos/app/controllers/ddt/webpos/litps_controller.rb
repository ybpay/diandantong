module Ddt
  module Webpos
    class LitpsController < Webpos::BaseController
      before_action :set_litp, only: [:confirm, :complete, :set_cook]
      check_permission :branch, :litp, { [:index, :counts, :cooks] => :show, confirm: :confirm_litp, complete: :complete_litp}
      def index
        if params[:filter_category_id].present?
          cids = @current_branch.categories.where(id: params[:filter_category_id]).with_sub_ids
          vids = Ddt::Category.get_variant_ids(cids)
          params[:q][:itemable_id_in] = vids
          params[:q][:itemable_type_eq] = "Ddt::Variant"
        end
        if params[:filter_cook_id].present?
          cook = @current_branch.managers.cooks.find_by(id: params[:filter_cook_id])
          if params[:q][:itemable_id_in].present?
            params[:q][:itemable_id_in] = params[:q][:itemable_id_in] & cook.concern_variant_ids
          else
            params[:q][:itemable_id_in] = cook.concern_variant_ids
          end
          params[:q][:itemable_type_eq] = "Ddt::Variant"
        end
        @litps = @current_branch.litps.in_hours(24).order(updated_at: :desc).where(params[:q]).paginate(page: params[:page], per_page: (params[:per_page] || 20))
      end

      def counts
        @pending_count = @current_branch.litps.by_state(:pending).in_hours(24).count
        @confirmed_count = @current_branch.litps.by_state(:confirmed).in_hours(24).count
        render json: {
          pending: @pending_count,
          confirmed: @confirmed_count,
        }
      end

      def cooks
        @cooks = @current_branch.managers.cooks
        render json: @cooks.map{|cook| cook.as_json(only: [:id, :name])}
      end

      def confirm
        if @litp.can_confirm?
          @litp.confirm
          render :show
        else
          render json: { errors: "不能标记开始烹饪" }, status: :bad_request
        end
      end

      def complete
         if @litp.can_complete?
          @litp.complete
          render :show
        else
          render json: { errors: "不能标记完成烹饪" }, status: :bad_request
        end
      end

      private

      def set_litp
        @litp = OrderService::Litps.find(params[:id])
      end
    end
  end
end
