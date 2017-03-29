module Ddt
  module Backend
    module Crm
      class VipInfosController < Backend::BaseCrmController
        # check_permission :shop, :vip_info
        before_action :set_vip_info, only: [:show, :edit, :update, :recharge_card_wallet, :recharge_credits_wallet, :exchange_card_wallet, :agree_apply_vip, :reject_apply_vip, :block]

        def index
          respond_to do |format|
            format.json {
              @q = @current_shop.vip_infos.includes(:credits_wallet, :card_wallet, :vip_level, user: :unique_user).ransack(params[:q])
              @vip_infos = @q.result(distinct: true).paginate(page: params[:page], per_page: (params[:per_page] || 10))
            }
            format.csv { send_data @current_shop.vip_infos.not_default_level.includes(:card_wallet, :credits_wallet).to_csv }
            format.xls { send_data @current_shop.vip_infos.not_default_level.includes(:card_wallet, :credits_wallet).to_xls, filename: 'vip_info.xls', type: "application/vnd.ms-excel"}
          end
        end

        def show
        end

        def new
          @vip_info = @current_shop.vip_infos.build
        end

        def edit
        end

        def create
          if vip_info_params[:vip_no].blank?
            vip_no = VipInfo.random_vip_no(@current_shop)
            @vip_info = @current_shop.vip_infos.build(vip_info_params.merge(vip_no: vip_no))
          else
            @vip_info = @current_shop.vip_infos.build(vip_info_params)
          end
          if @vip_info.save
            render :show
          else
            render json: { errors: @vip_info.errors.full_messages }, status: :bad_request
          end
        end

        def update
          if @vip_info.update(vip_info_params)
            render :show
          else
            render json: { errors: @vip_info.errors.full_messages }, status: :bad_request
          end
        end

        def credits_clear
          Ddt::BatchCreditsClearWorker.perform_async(@current_shop.id, params[:vip_info_ids])
          render json: :ok
        end

        def send_coupon
          @send_coupon_form = Ddt::SendCouponForm.new(params[:send_coupon_form].merge(shop: @current_shop))
          if @send_coupon_form.valid?
            @result = @send_coupon_form.perform
            render json: {result: @result}
          else
            render json: { errors: @send_coupon_form.errors.full_messages }, status: :bad_request
          end
        end

        def batch_agree_apply_vip
          @vip_infos = @current_shop.vip_infos.find(params[:vip_info_ids])
          @vip_infos.each do |vip_info|
            vip_info.agree_apply_vip
          end
          render json: :ok
        end

        def recharge_card_wallet
          @wallet = @vip_info.card_wallet
          @recharge = Ddt::WalletActions::Recharge.new(params[:recharge].merge(wallet: @wallet, operator: current_account))
          if @recharge.valid?
            @recharge.perform
            render :show
          else
            render json: { errors: @recharge.errors.full_messages }, status: :bad_request
          end
        end

        def recharge_credits_wallet
          @wallet = @vip_info.credits_wallet
          @get = Ddt::WalletActions::Get.new(params[:recharge].merge(wallet: @wallet, operator: current_account))
          if @get.valid?
            @get.perform
            render :show
          else
            render json: { errors: @get.errors.full_messages }, status: :bad_request
          end
        end

        def exchange_card_wallet
          @wallet = @vip_info.card_wallet
          @exchange = Ddt::WalletActions::Exchange.new(params[:exchange].merge(wallet: @wallet, operator: current_account))
          if @exchange.valid?
            @exchange.perform
            render :show
          else
            render json: { errors: @exchange.errors.full_messages }, status: :bad_request
          end
        end

        def agree_apply_vip
          @vip_info.agree_apply_vip
          render :show
        end

        def reject_apply_vip
          @vip_info.reject_apply_vip
          render :show
        end

        def block
          @vip_info.block(params[:block])
          render :show
        end

        def import
          message = ""
          import_failed_file = false
          if params[:file].present?
            # begin
            #   result = VipInfo.update_and_create_from_file(@current_shop, params[:file])
            #   if result
            #     message = "导入成功"
            #     status = :ok
            #   else
            #     message = "导入失败，请下载错误提示文件修改后再上传。"
            #     status = :bad_request
            #     import_failed_file = true
            #   end
            # rescue => e
            #   message = e.message
            #   status = :bad_request
            # end
            uploaded_file = @current_shop.uploaded_files.create(file: params[:file])
            VipInfo.delay.update_and_create_from_uploaded_file(@current_shop.id, uploaded_file.id)
            message = "文件上传成功，导入过程正在进行，请稍等"
            status = :ok
          else
            message = "请选择文件后再上传!"
            status = :bad_request
          end
          respond_to do |format|
            format.json{ render json: { message: message, file_upload_response: true, import_failed_file: import_failed_file }, status: status }
          end
        end

        def import_failed
          last_error = @current_shop.last_import_vip_info_error
          respond_to do |format|
            format.csv { send_data last_error.read}
          end
        end

        def batch_destroy
          @vip_infos = @current_shop.vip_infos.find(params[:vip_info_ids])
          @vip_infos.each do |vip_info|
            vip_info.destroy if vip_info.can_destroy?
          end
          render json: :ok
        end

        def orders
          set_vip_info
          @logs =@vip_info.orders.paginate(page: params[:page], per_page: (params[:per_page] || 10))
        end

        private
          def set_vip_info
            @vip_info = @current_shop.vip_infos.find(params[:id])
          end

          def vip_info_params
            params.require(:vip_info).permit(:name, :phone, :vip_level_id, :vip_no, :sex, :id_number, :birthday, :address, :email, :note, :pay_password)
          end
      end
    end
  end
end
