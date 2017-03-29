# encoding:utf-8
class ActionController::RequestForgeryProtection::ProtectionMethods::LogAndException
  def initialize(controller)
    @controller = controller
  end

  def handle_unverified_request
    req = @controller.request
    Rails.logger.error("InvalidAuthenticityToken url=#{req.url rescue nil}, referer=#{req.headers[:referer] rescue nil}, ip=#{req.ip}")
    raise ActionController::InvalidAuthenticityToken
  end
end

module Ddt
  class ModuleExpired < StandardError;
    attr_accessor :message
    def initialize(message)
      @message = message
    end
  end

  class ErrorNoAuthException < StandardError; end

  class BaseController < ActionController::Base

    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    # protect_from_forgery with: :exception
    protect_from_forgery with: :log_and_exception
    protect_from_forgery with: :null_session, if: Proc.new {|c| c.request.format.json? }

    delegate :url_helpers, to: 'Ddt::Core::Engine.routes'
    helper_method :mobile_device?, :wechat_device?
    attr_accessor :current_shop
    delegate :has_module?, :has_feature? , to: :current_shop

    before_action { TCC.enable }
    after_action { TCC.clear }

    #around_filter :global_request_logging
    def global_request_logging
      Rails.logger.info "REQUEST INSPECTOR"
      Rails.logger.info "  [REQUEST_URI] #{request.headers['REQUEST_URI'].inspect}"
      Rails.logger.info "  [RAW_POST]: #{request.raw_post.inspect}"
      Rails.logger.info "  [PARAMS]: #{request.params.inspect}"
      Rails.logger.info "  [HTTP_AUTHORIZATION] #{request.headers['HTTP_AUTHORIZATION'].inspect}"
      Rails.logger.info "  [CONTENT_TYPE]: #{request.headers['CONTENT_TYPE'].inspect}"
      Rails.logger.info "  [HTTP_ACCEPT] #{request.headers['HTTP_ACCEPT'].inspect}"
      Rails.logger.info "  [HTTP_HOST] #{request.headers['HTTP_HOST'].inspect}"
      Rails.logger.info "  [HTTP_USER_AGENT] #{request.headers['HTTP_USER_AGENT'].inspect}"
      begin
        yield
      ensure
        logger.info "response_status: #{response.body}"
      end
    end

    def set_current_shop
      slug = params[:shop_slug] || params[:shop_id] || (controller_name == 'shops' ? params[:id] : nil)
      @current_shop = Ddt::Shop.find(slug) if slug.present?

      if @current_shop.nil? && current_account && !current_account.is_admin?
        @current_shop = current_account.shop
      end

      Ddt::Shop.current = @current_shop
    end


    def mobile_device?
      result = (request.user_agent =~ /MicroMessenger|Mobile|webOS|android|iphone|ipad|ios|meego|ipod|kindle|phone|psp|symbian/i) or request.user_agent.nil?
      Rails.logger.info "request.user_agent is #{request.user_agent}" unless result
      result
    end

    def wechat_device?
      result = (request.user_agent =~ /MicroMessenger/i) or request.user_agent.nil?
      result
    end

    def ddt_app?
      request.user_agent =~ /ddtapp/i
    end

    def check_shop_ban
      if (current_account.nil? || !current_account.is_admin?) && @current_shop && @current_shop.is_ban?
        respond_to do |format|
          format.html{ render text: '系统供应商已暂停该门店服务，详情请联系您的系统供应商或代理商' }
          format.json{ render json: { errors: '系统供应商已暂停该门店服务，详情请联系您的系统供应商或代理商' }, status: :bad_request }
        end

      end
    end

  end
end
