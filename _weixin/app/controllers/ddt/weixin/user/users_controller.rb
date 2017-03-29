# encoding: utf-8
module Ddt
  module Weixin
    class User::UsersController < WeixinApplicationController
      respond_to :json
      def update_vip_info
        vip_info = @current_user.vip_info
        if !@current_user.vip?
          # vip申请
          if @current_shop.enable_vip_info_phone_validation? &&@current_shop.use_sms? && !vip_info.is_vip?
            sms_captcha = Ddt::SmsCaptcha.find(params[:sms_captcha_id])
            if sms_captcha.correct_code?(params[:sms_captcha_code], params[:vip_info][:phone])
              if vip_info.update(vip_info_params)
                sms_captcha.validate!
                vip_info.apply_vip(from_branch_id: params[:vip_info][:from_branch_id])
                render :show
              else
                render json: { errors: vip_info.errors.full_messages }, status: :bad_request
              end
            else
              render json: { errors: "验证码不正确" }, status: :bad_request
            end
          else
            if vip_info.update(vip_info_params)
              vip_info.apply_vip(from_branch_id: params[:vip_info][:from_branch_id])
              render :show
            else
              render json: { errors: vip_info.errors.full_messages }, status: :bad_request
            end
          end
        else
          # 修改
          if vip_info.update(vip_info_params)
            render :show
          else
            render json: { errors: vip_info.errors.full_messages }, status: :bad_request
          end
        end

      end

      def scan_code
        vip_info = @current_user.vip_info
        render json: vip_info.scan_code_html.merge({code: vip_info.get_scan_code})
      end

      def apply_vip
        vip_info = @current_user.vip_info
        vip_info.apply_vip
        render json: {}
      end

      def update_location
        if params[:user][:latitude].present? && params[:user][:longitude].present?
          if @current_user.update_columns(last_latitude: params[:user][:latitude], last_longitude: params[:user][:longitude], last_location_label: params[:user][:city_name])
            @current_user.reload
            render :show
          else
            render json: { errors: @current_user.errors.full_messages}, status: :bad_request
          end
        else
          render :show
        end
      end

      def update_pay_password
        vip_info = @current_user.vip_info
        if vip_info.authenticate(params[:current_pay_password])
          if vip_info.update(pay_password: params[:new_pay_password])
            render :show
          else
            render json: { errors: vip_info.errors.full_messages }, status: :bad_request
          end
        else
          render json: { errors: ['当前支付密码错误']}, status: :bad_request
        end
      end

      def authenticate_password
        @result =  @current_user.vip_info.authenticate(params[:password])
        render json: { result: @result }
      end

      def send_vip_info_phone_validation_code
        if @current_shop.enable_vip_info_phone_validation?
          client_ip = request.remote_ip
          captcha = Ddt::SmsCaptcha.new(phone: params[:to], ip: client_ip, session_hash: session.try(:id))
          short_message = Ddt::ShortMessage.build_validation_short_message(@current_shop, @current_user.vip_info, params[:to], captcha)
          if short_message.save
            render json: {id: short_message.sms_captcha.id}
          else
            render json: {errors: short_message.errors.full_messages}, status: :bad_request
          end
        else
          render json: { errors: "未启用短信验证码" }, status: :bad_request
        end
      end

      def send_validation_code
        client_ip = request.remote_ip
        captcha = Ddt::SmsCaptcha.new(phone: params[:to], ip: client_ip, session_hash: session.try(:id))
        short_message = Ddt::ShortMessage.build_validation_short_message(@current_shop, @current_user.vip_info, params[:to], captcha)
        if short_message.save
          if short_message.sms_captcha.id.present?
            render json: {id: short_message.sms_captcha.id}
          else
            render json: {errors: short_message.sms_captcha.errors.full_messages}, status: :bad_request
          end
        else
          render json: {errors: short_message.errors.full_messages}, status: :bad_request
        end
      end

      def is_correct_code
        if params[:sms_captcha_code].blank?
          render json: {errors: '请输入验证码'}, status: :bad_request
          return
        end
        if params[:sms_captcha_id].blank?
          render json: {errors: '请点击获取验证码'}, status: :bad_request
          return
        end
        sms_captcha = Ddt::SmsCaptcha.find(params[:sms_captcha_id])
        if sms_captcha.short_message.owner == @current_user.vip_info && sms_captcha.correct_code?(params[:sms_captcha_code], params[:phone])
          render json: {is_correct: true}
        else
          render json: {errors: '验证码错误，请重新输入'}, status: :bad_request
        end
      end

      def show
      end

      def bind_vip
        
        if @current_shop.enable_vip_info_phone_validation? 
          sms_captcha = Ddt::SmsCaptcha.find(params[:sms_captcha_id])
          unless sms_captcha.short_message.owner == @current_user.vip_info && sms_captcha.correct_code?(params[:sms_captcha_code], params[:phone])
            render json: { errors: "验证码填写错误!" }, status: :bad_request  
            return
          end
        end
        @new_vip = @current_shop.vip_infos.find_by_phone(params[:phone])
        if @new_vip.present? && @new_vip != @current_user.vip_info && !@new_vip.builtin? && @new_vip.authenticate(params[:password])
          begin
            Ddt::VipInfo.merge_info(@current_user.vip_info, @new_vip)
            sms_captcha.validate!
            @current_user.reload
            render :show
          rescue Exception => e
            render json: { errors: e.message }, status: :bad_request
          end
        else
          render json: { errors: "手机号或密码错误!" }, status: :bad_request
        end
      end

      def card_wallet_logs
        if @current_user.vip?
          @wallet_logs = @current_user.vip_info.card_wallet.wallet_logs.where(reason: Ddt::WalletLog.user_card_reasons(accessible_by: :user)).order(created_at: :desc)
        else
          render json: []
        end
      end

      def credits_wallet_logs
        @q = @current_user.vip_info.credits_wallet.wallet_logs.where(reason: Ddt::WalletLog.user_credits_reasons).ransack(params[:q])
        @wallet_logs = @q.result.order(created_at: :desc)
        render :card_wallet_logs
      end

      private
      def vip_info_params
        unless @current_user.vip?
          params.require(:vip_info).permit(:name, :phone, :sex, :address, :email, :id_number, :birthday, :source_user_id)
        else
          params.require(:vip_info).permit(:sex, :address, :email, :id_number, :birthday)
        end
      end
    end
  end
end
