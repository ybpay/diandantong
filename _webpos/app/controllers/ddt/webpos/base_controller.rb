module Ddt
  module Webpos
    class BaseController < Ddt::BaseController
      include DeviseUrlHelper
      include CheckFeature
      include CheckPermission
      before_action :set_terminal_id
      before_action :set_track_from
      before_action :authenticate_webpos_webpos_account!
      layout false
      before_action :set_current_shop
      before_action :set_current_branch
      before_action :authorize_shop_account
      before_action :check_shop_ban
      before_action :check_branch_online
      before_action :set_authorizer

      check_feature :webpos
      #before_action :check_multi_branches
      delegate :has_feature?, to: :current_shop

      skip_before_action :verify_authenticity_token

      rescue_from Error::NoFeatureError, Error::FeatureNotEnabled, Error::NoPermissionError, Ddt::ErrorNoAuthException do |exception|
        if current_account.nil?
          render json: {
            code: 0,
            errors: ['您的登录已过期，请返回重新登录']
          }, status: :bad_request
        else
          render json: {
            code: 0,
            errors: [exception.message]
          }, status: :bad_request
        end
      end

      rescue_from Ddt::OrderService::Api::UpdateLockError do |exception|
        render json: { error: "操作失败，请重新尝试" }, status: :bad_request
      end

      helper_method :can?, :managed_branches, :managed_branch_ids
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

      helper_method :current_shop, :current_branch
      def current_shop
        @current_shop
      end

      def current_branch
        @current_branch
      end

      def can?(scope, target, action, options={})
        if current_account == @authorizer
          current_account.can?(scope, target, action, options)
        else
          current_account.can?(scope, target, action, options) || @authorizer.can?(scope, target, action, options)
        end
      end

      def authorize!(scope, target, action, options={})
        unless can?(scope, target, action, options)
          raise Error::NoPermissionError.new(Permission.new(scope, target, action, options))
        end
      end

      private
      def authorize_shop_account
        if current_account && !current_account.is_admin? && @current_shop.id != current_account.shop_id
          raise ErrorNoAuthException.new("没有权限")
        end
        Ddt::Account.current = current_account
      end

      def set_current_branch
        if params[:branch_id].present?
          @current_branch = @current_shop.branches_include_abstract.find(params[:branch_id])
        elsif controller_name == 'branches' && params[:id].present?
          @current_branch = @current_shop.branches_include_abstract.find(params[:id])
        end
        if @current_branch.present? && !@current_branch.is_abstract?
          unless managed_branch_ids.include?(@current_branch.id)
            raise ErrorNoAuthException.new("没有权限")
          end
        end
      end

      def check_multi_branches
        if @current_shop.is_multi_branches? && !Rails.env.development? && @current_account.present? && !@current_account.is_boss?
          render plain: "多店旗舰版暂不开放收银系统"
        end
      end

      def check_branch_online
        if Ddt::CsBranchBinding.deny_online_access?(@current_branch, request)
          respond_to { |format|
            format.html {
              render '门店未连网,不接受在线点餐'
            }
            format.json {
              render :json => {errors: '门店未连网,不接受在线点餐'}, status: :bad_request
            }
          }
        end
      end

      def set_track_from
        @track_from = :FromWebpos
      end

      def set_terminal_id
        @terminal_id = params[:terminal_id]
        RequestStore.store[:terminal_id] = @terminal_id
      end

      def set_authorizer
        @authorizer = params[:authorizer_id].present? ? current_shop.accounts.find(params[:authorizer_id]) : current_account
      end


    end
  end
end
