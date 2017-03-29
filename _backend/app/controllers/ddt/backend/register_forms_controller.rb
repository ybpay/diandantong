module Ddt
  class Backend::RegisterFormsController < BaseController
    include Ddt::Backend::DeviseUrlHelper
    include Ddt::Backend::SetAgentBrand
    helper_method :can?

    before_action :find_register_form, only: [:edit, :update, :complete]
    layout Proc.new {
      if mobile_device?
        "ddt/layouts/backend_weixin"
      else
        "ddt/layouts/backend_empty"
      end
    }

    def new
      @register_form = Ddt::RegisterForm.new(shop_agent_no: params[:agent_no])
      if mobile_device?
        render :new_m
      end
    end

    def create
      # 针对注册了手机号却没有填写详细信息的用户做细化判断
      @register_form = Ddt::RegisterForm.new(register_form_params.merge(captcha_id: session[:captcha_id]))

      @register_form.track_from = :FromBackend
      if mobile_device?
        @register_form.track_from = :FromMobile
        if wechat_device?
          @register_form.track_from = :FromWechat
        end
      end
      if @register_form.save
        redirect_to edit_backend_register_form_path(access_token: @register_form.access_token)
      else
        if mobile_device?
          render :new_m
        else
          render :new
        end
      end
    end

    def edit
      if mobile_device?
        render :edit_m
      end
    end

    def update
      if @register_form.update(register_form_params)
 
        sign_up_params = register_form_params.merge(phone: @register_form.phone, "shop_attributes" => {"address"=>@register_form.shop_address, "agent_no"=>@register_form.shop_agent_no})
        @account = Ddt::Account.new(sign_up_params)
        captcha = nil
        if @register_form.captcha_id.present?
          captcha = Ddt::SmsCaptcha.find(@register_form.captcha_id)
          @account.captcha = captcha.id
          @account.captcha_valid = captcha.present? && captcha.correct_code?(@register_form.captcha.to_s, @register_form.phone)
        else
          @account.captcha_valid = false
        end
        
        if @account.init(sign_up_params, track_from: @register_form.track_from)
          @account.roles = @account.shop.roles.boss_role
          @register_form.update_attribute(:shop_id, @account.shop_id)

          #只有官网自己注册的用户才有试用所有模块7天的权限
          Ddt::FeatureModuleGroup.send(:trial)[:modules].each do |fm|
            feature_module_config = @account.shop.feature_modules_configs.find_by(feature_module: fm)
            fmcs = []
            unless feature_module_config.present?
              feature_module_config = @account.shop.feature_modules_configs.build(feature_module: fm, expired_at: 7.days.from_now)
              fmcs << feature_module_config
            end
            Ddt::FeatureModulesConfig.import(fmcs)
          end
          redirect_to complete_backend_register_form_path(access_token: @register_form.access_token)

        else
          if mobile_device?
            render :edit_m
          else
            render :edit
          end
        end

      else
        if mobile_device?
          render :edit_m
        else
          render :edit
        end
      end
    end

    def complete
      if mobile_device?
        render :complete_m
      else
        render :complete
      end
    end

    def send_sms_captcha
      #
      # 发送短信验证码前，如同一 IP 请求过频繁，则要求用户输入图片验证码
      # EasyCaptch 使用 session[:captcha] 记录验证码
      #
      if params[:phone].blank?
        render json: {errors: '手机号码输入非法'}, status: :bad_request
        return 
      end

      if Ddt::Account.find_by(phone: params[:phone]).present?
        render json: {errors: '该手机号码已经被注册', notunique: true}, status: :bad_request
        return 
      end

      client_ip = request.env['HTTP_X_FORWARDED_FOR'] || request.remote_ip
      if Ddt::SmsCaptcha.need_image_captcha?(client_ip, session.try(:id))
        if params[:image_captcha].present?
          unless captcha_valid? params[:image_captcha]
            render json: {errors: '输入的图片验证码错误', image_captcha: Base64.encode64(generate_captcha)}, status: :bad_request
            return
          end
        else
          render json: {errors: '您请求短信验证码的频率太频繁，请先输入图片验证码', image_captcha: Base64.encode64(generate_captcha)}, status: :bad_request
          return
        end
      end

      captcha = Ddt::SmsCaptcha.new(phone: params[:phone], ip: client_ip, session_hash: session.try(:id))
      short_message = Ddt::ShortMessage.new(
        to: captcha.phone,
        sms_captcha: captcha,
        sms_type: :captcha
      )

      if short_message.save
        session[:captcha_id] = captcha.id
        render json: {}
      else
        render json: {errors: short_message.errors.full_messages.join(", ")}, status: :bad_request
      end
    end

    def check_sms_captcha
      if params[:captcha].blank?
        render json: {errors: '请输入验证码'}, status: :bad_request
        return
      end

      if session[:captcha_id].blank?
        render json: {errors: '请点击发送短信验证码'}, status: :bad_request
        return
      end

      if session[:captcha_id].present?
        captcha = Ddt::SmsCaptcha.find_by(id: session[:captcha_id])
        captcha_valid = captcha.present? && captcha.correct_code?(params[:captcha].to_s, params[:phone])
      else
        captcha_valid = false
      end

      if captcha_valid
        render json: {} 
      else
        render json: {errors: '验证码填写不正确'}, status: :bad_request
      end
    end

    private
    def find_register_form
      @register_form = Ddt::RegisterForm.find_by(access_token: params[:access_token])
      if @register_form.blank?
        raise '输入非法'
      end
    end

    def register_form_params
      params.require(:register_form).permit(:login_id, :email, :password, :password_confirmation, :phone, :captcha, :captcha_id, :accept_term, :shop_agent_no, :shop_address)
    end
  end
end