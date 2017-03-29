module Ddt
  module CommonApi
    module V1
      class TokenError < StandardError; end;
      class TokenExpiredError < StandardError; end;
      class NoAuthError < StandardError; end;
      class BaseController < ActionController::Base
        include CheckFeature
        include CheckPermission
        respond_to :json, :html


        before_action :authenticate_account_from_token!
        before_action :set_track_from
        before_action :set_terminal_id
        before_action :set_current_shop
        before_action :set_current_branch
        before_action :check_branch_online
        before_action :check_ban_login
        check_feature :common_api


        rescue_from TokenError do |exception|
          respond_to do |format|
            format.json{ render json: { error_code: 11, msg: "登录失败" }, status: 401 }
            format.html{ render text: "登录失败", layout: false, status: 401 }
          end
        end

        rescue_from TokenExpiredError do |exception|
          respond_to do |format|
            format.json{ render json: { error_code: 12, msg: "Token过期" }, status: 401}
            format.html{ render text: "Token过期", layout: false, status: 401 }
          end
        end

        rescue_from NoAuthError do |exception|
          respond_to do |format|
            format.json{ render json: { error_code: 13, msg: "权限不足" }, status: 401}
            format.html{ render text: "权限不足", layout: false, status: 401 }
          end
        end

        rescue_from Error::NoPermissionError do |exception|
          respond_to do |format|
            format.json{ render json: {msg: exception.message }, status: 400}
            format.html{ render text: exception.message, layout: false, status: 401 }
          end
        end

        rescue_from ::Ddt::PaymentException do |exception|
          respond_to do |format|
            format.json{ render json: {msg: exception.message, data: exception.log_json_entry}, status: 400}
            format.html{ render text: exception.message, layout: false, status: 401 }
          end
        end

        rescue_from ::Ddt::Error::NoFeatureError, ::Ddt::Error::FeatureNotEnabled do |exception|
          respond_to do |format|
            format.json{ render json: {msg: exception.message }, status: 400}
            format.html{ render text: exception.message, layout: false, status: 401 }
          end
        end





        rescue_from Ddt::OrderService::Api::UpdateLockError do |exception|
          respond_to do |format|
            format.json{ render json: { msg: "操作失败，请重新尝试" }, status: :bad_request}
            format.html{ render text: "操作失败，请重新尝试", layout: false, status: 401 }
          end
        end

        rescue_from ActionController::ParameterMissing do |exception|
          respond_to do |format|
            Rails.logger.info "[ParameterMissing common_api] #{exception.message}"
            format.json{ render json: { msg: "参数非法"}, status: :bad_request}
            format.html{ render text: "非法的操作", layout: false, status: 401}
          end
        end



        helper_method :current_account, :current_shop , :current_branch
        helper_method :can?, :managed_branches, :managed_branch_ids
        delegate :can?, :authorize!, to: :current_account

        def managed_branches
          if current_account.is_admin?
            @current_shop.branches
          else
            current_account.managed_branches
          end
        end

        def managed_branch_ids
          if current_account.is_admin?
            @current_shop.managed_branch_ids
          else
            current_account.managed_branch_ids
          end
        end

        def current_account
          @current_account
        end

        def paginate(obj)
          obj.paginate(page: params[:page], per_page: (params[:per_page] || 20))
        end

        def current_shop
          @current_shop ||= current_account.shop
        end

        def current_branch
          @current_branch
        end

        private

        def set_authorizer
          @authorizer = params[:authorizer_id].present? ? current_shop.accounts.find(params[:authorizer_id]) : current_account
        end

        def set_track_from
          if params[:track_from].blank?
            params[:track_from] = ddt_app? ? 'FromApp' : 'FromWebpos'
          end
          @track_from = params[:track_from]
        end

        def mobile_device?
          result = (request.user_agent =~ /MicroMessenger|Mobile|webOS|android|iphone|ipad|ios|meego|ipod|kindle|phone|psp|symbian/i) or request.user_agent.nil?
          Rails.logger.info "request.user_agent is #{request.user_agent}" unless result
          result
        end

        def ddt_app?
          request.headers["X-DDB-Agent"] =~ /ddtapp/i
        end

        def set_terminal_id
          @terminal_id = params[:terminal_id]
        end

        def set_current_shop
          slug = params[:shop_slug] || params[:shop_id] || (controller_name == 'shops' ? params[:id] : nil)
          @current_shop = Ddt::Shop.find(slug) if slug.present?

          if @current_shop.nil? && current_account && !current_account.is_admin?
            @current_shop = current_account.shop
          end

          Ddt::Shop.current = @current_shop
        end

        def set_current_branch
          key = params[:branch_id] || (controller_name == 'branches' ? params[:id] : nil)
          if key.present?
            @current_branch = current_account.managed_branches.find_by(id: key)
            raise NoAuthError.new if @current_branch.nil?
          end
        end

        def authenticate_account_from_token!
          login_id = request.headers["X-Account-Login-Id"] || params[:login_id]
          token = request.headers["X-Account-Authentication-Token"] || params[:authentication_token]
          account = login_id && Account.where(["lower(login_id) = :value OR lower(email) = :value", { value: login_id.downcase }]).first
          if account && Devise.secure_compare(account.authentication_token, token)
            if account.authentication_token_expired?
              raise TokenExpiredError.new
            else
              @current_account = account
            end
          else
            raise TokenError.new
          end
        end

        def check_branch_online
          if Ddt::CsBranchBinding.deny_online_access?(@current_branch, request)
            respond_to { |format|
              format.html {
                render text: '门店未连网,不接受在线点餐'
              }
              format.json {
                render :json => {errors: '门店未连网,不接受在线点餐'}, status: :bad_request
              }
            }
          end
        end

        def check_ban_login
          if ddt_app? &&
             current_account.present? &&
             current_account.ban_login_app_when_no_open &&
             @current_branch.present? &&
             !['branches', 'shops', 'accounts', 'permissions', 'notifications'].include?(controller_name) &&
             !@current_branch.is_in_service
            render json: {errors: '门店未营业, 操作不允许'}, status: :bad_request
            return
          end
        end

      end
    end
  end
end
