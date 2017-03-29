module Ddt
  module Webpos
    class VipInfosController < Webpos::BaseController
      before_filter :set_vip_info, only: [:show, :update, :wallet_logs, :merge, :become, :reject]
      before_filter :set_wallet, only: [:wallet_logs]
      check_permission :shop, :user, {
        [:index, :show, :get_by_scan_code, :wallet_logs] => :show,
        create: :create,
        [:update, :merge, :become, :reject] => :update,
      }

      def index
        @q = @current_shop.vip_infos.includes(:vip_level, :card_wallet, :credits_wallet, :base_users).ransack(params[:q])
        @vip_infos = @q.result(distinct: true).paginate(page: params[:page], per_page: (params[:per_page] || 20))
      end

      def create

        if vip_info_params[:vip_no].blank?
          vip_no = Ddt::VipInfo.random_vip_no(@current_shop)
          @vip_info = @current_shop.vip_infos.build(vip_info_params.merge(vip_no: vip_no))
        else
          @vip_info = @current_shop.vip_infos.build(vip_info_params)
        end

        if @vip_info.save
          create_phone_user(@vip_info)
          render :show
        else
          render json: { errors: @vip_info.errors.full_messages }, status: :bad_request
        end
      end

      def update
        if @vip_info.update_times == 0
          if @vip_info.update(vip_info_params)
            @vip_info.increment!(:update_times)
            render :show
          else
            render json: { errors: @vip_info.errors.full_messages }, status: :bad_request
          end
        else
          render json: { errors: "更新次数受限" }, status: :bad_request
        end
      end

      def show
        if @vip_info.blank?
          render json: { errors: "未找到该会员" }, status: :bad_request
        end
      end

      def get_by_scan_code
        @vip_info = Ddt::VipInfo.get_by_scan_code(params[:scan_code])
        if @vip_info.present?
          render :show
        else
          render json: { errors: "付款码不正确或已过期" }, status: :bad_request
        end
      end

      def wallet_logs
        @q = @wallet.wallet_logs.includes(:branch).ransack(params[:q])
        @wallet_logs = @q.result(distinct: true).paginate(page: params[:page], per_page: (params[:per_page] || 20))
      end

      def merge
        @source_vip_info = @current_shop.vip_infos.find(params[:source_vip_info_id])
        if @source_vip_info.can_merge_to(@vip_info)
          Ddt::VipInfo.merge_info(@source_vip_info, @vip_info)
          render :show
        else
          render json: { errors: @source_vip_info.errors.full_messages }, status: :bad_request
        end
      end

      def become
        if @vip_info.update(vip_info_params) && @vip_info.agree_apply_vip
          render :show
        else
          render json: { errors: @vip_info.errors.full_messages }, status: :bad_request
        end
      end

      def reject
        if @vip_info.reject_apply_vip
          render :show
        else
          render json: { errors: @vip_info.errors.full_messages }, status: :bad_request
        end
      end

      private

      def create_phone_user(vip_info)
         @current_shop.phone_users.create(phone: vip_info.phone, vip_info_id: vip_info.id)
      end

      def set_vip_info
        @vip_info = @current_shop.vip_infos.includes(:vip_level, :card_wallet, :credits_wallet, :base_users).where("ddt_vip_infos.id = :q or ddt_vip_infos.vip_no = :q", { q: params[:id] }).first
      end

      def set_wallet
        type = params[:wallet_logs_type]
        @wallet = if type == 'credits_wallet_logs'
          @vip_info.credits_wallet
        elsif type == 'card_wallet_logs'
          @vip_info.card_wallet
        end
      end

      def vip_info_params
        params.require(:vip_info).permit(:vip_no, :name, :phone, :vip_level_id, :birthday, :from_branch_id)
      end

    end
  end
end
