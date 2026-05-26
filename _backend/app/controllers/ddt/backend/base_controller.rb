require 'ddt_core'
module Ddt
  module Backend
    class BaseController < Ddt::BaseController
      before_action :check_host
      include CheckPermission
      include CheckFeature
      include DeviseUrlHelper
      include Backend::TempAttribute
      include Ddt::Backend::SetAgentBrand
      before_action :authenticate_account!
      before_action :set_current_account
      before_action :set_current_shop
      before_action :set_track_from
      before_action :check_shop_ban
      before_action :set_current_branch
      before_action :authorize_shop_account
      layout 'ddt/layouts/backend'
      helper_method :filted_params
      helper_method :has_feature?
      helper_method :has_module?

      check_feature :backend

      # before_action do
      #   resource = controller_name.singularize.to_sym
      #   method = "#{resource}_params"
      #   params[resource] &&= send(method) if respond_to?(method, true)
      # end

      rescue_from Error::NoPermissionError, Ddt::ErrorNoAuthException do |exception|
        if current_account.nil?
          session[:next] = request.fullpath
          respond_to do |format|
            format.html{ redirect_to backend_login_url, :alert => t("You have to log in to continue") }
            format.json{ render json: {error: "尚未登录 #{exception.message}"}, status: 401 }
          end
        else
          respond_to do |format|
            format.html do
              if request.env["HTTP_REFERER"].present?
                redirect_to :back, :alert => exception.message
              else
                redirect_to get_backend_root_path, :alert => exception.message
              end
            end
            format.js{ render js: "bootbox.hideAll();bootbox.alert('#{exception.message}');" }
            format.json{ render json: {error: "没有权限 #{exception.message}"}, status: :bad_request }
          end
        end
      end

      rescue_from Error::NoFeatureError,Error::FeatureNotEnabled do |exception|
        if current_account.nil?
          redirect_to backend_login_url, alert: exception.message
        else
          respond_to do |format|
            format.html do
              if request.env["HTTP_REFERER"].present?
                redirect_to :back, :alert => exception.message
              else
                redirect_to get_backend_root_path, :alert => exception.message
              end
            end
            format.js { render js: "bootbox.hideAll();bootbox.alert('#{exception.message}');" }
            format.json { render json: {error: exception.message}, status: :bad_request}
          end
        end
      end

      rescue_from ActionController::UnknownFormat do |exception|
        render plain: "直接点击就行呢 :)"
      end

      def filted_params
        black_list = [:controller, :action, :authenticity_token, :flash]
        params.delete_if{|key, value| black_list.include? key.to_sym}
      end

      helper_method :can?, :managed_branches, :managed_branch_ids
      delegate :can?, :authorize!, to: :current_account
      def managed_branches
        @managed_branches ||= if current_account.is_admin?
          @current_shop.branches_include_abstract
        else
          current_account.managed_branches
        end

      end

      def managed_branch_ids
        @managed_branch_ids ||= if current_account.is_admin?
          @current_shop.branches_include_abstract_ids
        else
          current_account.managed_branch_ids
        end
      end

       protected

      def authorize_shop_account
        if current_account && !current_account.is_admin? && @current_shop != current_account.shop
          raise ErrorNoAuthException.new("没有权限")
        end
      end

      def set_current_branch
        if params[:branch_id].present?
          @current_branch = @current_shop.branches_include_abstract.find(params[:branch_id])
        elsif controller_name == 'branches' && params[:id].present?
          @current_branch = @current_shop.branches_include_abstract.find(params[:id])
        end

        return if current_account.is_admin?
        if @current_branch.present? && !@current_branch.is_abstract?
          unless managed_branches.include?(@current_branch)
            raise ErrorNoAuthException.new("没有权限")
          end
        end
      end

      def set_current_account
        Ddt::BaseUser.current = nil
        Ddt::Account.current = current_account
      end

      def check_host
        return if Ddt::Host::LOCAL.include? request.host

        splits = Ddt::Host::DEPLOY.split(':')
        if splits.length == 2
          return if Ddt::Host::DEPLOY == "#{request.host}:#{request.port}"
        elsif splits.length == 1
          return if Ddt::Host::DEPLOY == request.host and request.port == 80
        end

        if Ddt::Shop.of_oem.where(:custom_domain => request.host).any?
          return
        end

        if Ddt::Agent.of_oem.where(:domain => request.host).any?
          return
        end

        redirect_to "http://#{Ddt::Host::DEPLOY}"
      end

      def set_track_from
        @track_from = :FromBackend
      end

    end
  end
end
