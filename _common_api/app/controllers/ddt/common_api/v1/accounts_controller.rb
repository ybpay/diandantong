module Ddt
  module CommonApi
    module V1
      class AccountsController < V1::BaseController
        skip_before_action :authenticate_account_from_token!, only: [:login, :send_sms_captcha, :register]

        check_permission :shop, :account, {
          index: :show,
          create: :create,
          update: :update,
          destroy: :destroy
        }, only: [:index, :create, :update, :destroy]

        # resources :accounts
        before_action :set_account_collection, only: [:index]
        before_action :set_account, only: [:update, :destroy]
        def index
          @q = @collection.ransack(params[:q])
          @accounts = @q.result(distinct: true).paginate(page: params[:page])
        end

        def create
          @account = @current_shop.accounts.build(account_params)
          @account.captcha_valid = true
          if @account.save
            render '_detail'
          else
            render json: { errors: @account.errors.full_messages }, status: :bad_request
          end
        end

        def destroy
          if @account.id == current_account.id
            render json: {errors: ["删除失败，不能删除自己"]}, status: :bad_request
            return
          end
          if @account.destroy!
            render json: {}
          else
            render json: {errors: @account.errors.full_messages}, status: :bad_request
          end
        end

        def update
          if @account.update(account_update_params)
            @account.touch
            render '_detail'
          else
            render json: {errors: @account.errors.full_messages}, status: :bad_request
          end
        end

        # resource :account
        def update_channel
          if current_account.present? && params[:os_type].present? && params[:channel_id].present?
              current_account.update_push_channel(params.permit(:os_type, :channel_id, :is_oem))
              render json: {}
          else
              render json: {errors: "更新失败，未登录或参数不全"}
          end
        end

        def login
          @account = Account.find_first_by_auth_conditions(login: params[:login_id])
          if @account.present? && @account.valid_password?(params[:password])
            if ddt_app? && @account.ban_login_app_when_no_open && !@account.any_branch_in_service?
              render json: {errors: '门店未营业，不允许登陆！'}, status: :bad_request
              return
            end
            if params[:os_type].present? && params[:channel_id].present?
              @account.update_push_channel(params.permit(:os_type, :channel_id, :is_oem))
            else
              logger.warn "invalid log content: #{params[:os_type]}, #{params[:channel_id]}"
            end
            @account.refresh_authentication_token
            @account.update_tracked_fields!(request)
            render :login
          else
            render json: { errors: "帐号或密码错误" }, status: :bad_request
          end
        end

        def logout
          if params[:channel_id].present? && current_account.present?
            push_channel = current_account.push_channels.find_by(j_push_channel_id: params[:channel_id])
            push_channel.expire_it
            render json: {}
          elsif !current_account.errors.blank?
            render json: {errors: current_account.errors.full_messages}, status: :bad_request
          else 
            render json: {}
          end
        end

        def auth
          if params[:password].present? && current_account.present?
            render json: {ok: current_account.valid_password?(params[:password])}
          else
            render json: {ok: false}
          end
        end

        def report_location
          location  = params[:locations].first
          if location.present?
            @current_account.locations.create!(
                longitude: location[:longitude],
                latitude: location[:latitude],
                sampled_at: location[:sampled_at]
            )
            render json: {}
          else
            render json: { errors: '上报的地理位置数据不能为空或格式不对'}, status:  :bad_request
          end

        end

        def send_sms_captcha
          client_ip = request.remote_ip
          if SmsCaptcha.need_image_captcha?(client_ip, session.try(:id))
            render json: { errors: '您请求短信验证码的频率太频繁，请稍候尝试' }, status: :bad_request
            return
          end

          captcha = Ddt::SmsCaptcha.new(phone: params[:phone], ip: client_ip, session_hash: session.try(:id))
          short_message = Ddt::ShortMessage.new(
            to: captcha.phone,
            sms_captcha: captcha,
            sms_type: :captcha
          )
          if short_message.save
            render json: { captcha_id: captcha.id, msg: '验证码已经发送到您的手机上'}
          else
            render json: {errors: short_message.errors.full_messages.join(", ")}, status: :bad_request
          end
        end

        def show
          render :show
        end

        def register
          params[:shop_attributes] = Hash.new
          if params[:agent_no].present?
            params[:shop_attributes][:agent_no] = params[:agent_no]
            params.delete(:agent_no)
          end
          if params[:address].present?
            params[:shop_attributes][:address] = params[:address]
            params.delete(:address)
          end

          new_params = {}
          [:login_id, :name, :email, :phone, :password, :password_confirmation].each {|key| new_params[key] = params[key]}
          account = Account.new(new_params)
          captcha = SmsCaptcha.find(params[:captcha_id])
          if captcha.present?
            account.captcha = captcha.id
            account.captcha_valid = captcha.correct_code?(params[:captcha].to_s, params[:phone])
          else
            account.captcha_valid = false
          end

          if account.init(params, track_from: :FromApp)
            account.roles = account.shop.roles.boss_role
            render json: account.as_json(only: [:id, :login_id, :name, :authentication_token, :phone, :email, :last_sign_in_at, :last_sign_in_ip])
          else
            render json: { errors: account.errors.full_messages.join('. ')}, status: :bad_request
          end
        end

        def permissions
          render json: current_account.all_permissions
        end

        private

          def set_account
            set_account_collection
            @account = @collection.find(params[:id])
          end

          def set_account_collection
            if current_account.is_worker?
              @collection = @current_shop.accounts.manage_by_worker(current_account)
            else
              @collection = @current_shop.accounts
            end
          end

          def account_update_params
            params.require(:account).permit(:phone, :name, :email, :notification_email, :receive_email, :role_ids_string, :manage_branch_ids_string, :ban_login_app_when_no_open)
          end

          def account_params
            params.require(:account).permit(:phone, :name, :password, :password_confirmation, :login_id, :email, :notification_email, :receive_email, :role_ids_string, :manage_branch_ids_string, :ban_login_app_when_no_open)
          end
      end
    end
  end
end
