module Ddt
  class Backend::User::BaseUsersController < Backend::BaseController
    check_permission :shop, :user, {
      [:index, :normal_users, :vip_users, :find_by_user_open_id, :show, :card_wallet_logs, :credits_wallet_logs, :recharge_orders] => :show,
      [:edit, :update] => :update,
      [:recharge_card_wallet, :get_recharge_card_wallet] => :recharge_card_wallet,
      [:exchange_card_wallet, :get_exchange_card_wallet] => :exchange_card_wallet,
      [:exchange_credits_wallet, :get_exchange_credits_wallet] => :exchange_credits_wallet,
      [:get_send_coupon, :send_coupon] => :send_coupon,
    }
    before_action :set_base_user, only: [:show, :edit, :update, :destroy,
                                         :get_recharge_card_wallet, :get_exchange_card_wallet, :get_exchange_credits_wallet,
                                         :exchange_card_wallet, :recharge_card_wallet, :exchange_credits_wallet,
                                         :card_wallet_logs, :credits_wallet_logs, :recharge_orders,
                                         :agree_apply_vip, :reject_apply_vip]

    def index
      @q = @current_shop.base_users.includes([:unique_user, :vip_info => [:vip_level]]).ransack(params[:q])
      @base_users = @q.result(distinct: true).paginate(page: params[:page])
      @search_form_path = backend_shop_base_users_path(@current_shop)
      respond_to do |format|
        format.html
        format.json {
          render :json => @base_users.flatten.map(&:select_json)
        }
      end
    end

    def normal_users
      @q = @current_shop.base_users.of_normal_users.ransack(params[:q])
      @base_users = @q.result(distinct: true).paginate(page: params[:page])
      @search_form_path = normal_users_backend_shop_base_users_path(@current_shop)
      respond_to do |format|
        format.html { render 'index' }
        format.json {
          render :json => @base_users.flatten.map(&:select_json)
        }
      end
    end

    def vip_users
      @q = @current_shop.base_users.of_vip_users.ransack(params[:q])
      @base_users = @q.result(distinct: true).paginate(page: params[:page])
      @search_form_path = vip_users_backend_shop_base_users_path(@current_shop)
      respond_to do |format|
        format.html { render 'index' }
        format.json {
          render :json => @base_users.flatten.map(&:select_json)
        }
      end
    end

    def find_by_user_open_id
      @q = @current_shop.users.ransack(params[:q])
      # @base_users 实际包含的是User类型对象
      @base_users = @q.result(distinct: true).paginate(page: params[:page])
      @search_form_path = find_by_user_open_id_backend_shop_base_users_path(@current_shop)
    end

    def show
      render layout: "ddt/layouts/backend/user"
    end

    def edit
      render layout: "ddt/layouts/backend/user"
    end

    def update
      if @base_user.update(base_user_params)
        redirect_to backend_shop_base_user_path(@current_shop, @base_user), notice: "#{t('activerecord.models.ddt/base_user')} 更新成功."
      else
        render :edit, layout: "ddt/layouts/backend/user"
      end
    end

    def get_recharge_card_wallet
      @recharge = Ddt::WalletActions::Recharge.new
      @wallet = @base_user.card_wallet
      render layout: "ddt/layouts/backend/user"
    end

    def recharge_card_wallet
      @wallet = @base_user.card_wallet
      @recharge = Ddt::WalletActions::Recharge.new(params[:wallet_actions_recharge].merge(wallet: @wallet, operator: current_account))
      respond_to do |format|
        format.html do
          if @recharge.valid?
            @recharge.perform
            redirect_to card_wallet_logs_backend_shop_base_user_path(@current_shop, @base_user), notice: "充值成功！"
          else
            render 'get_recharge_card_wallet', layout: "ddt/layouts/backend/user"
          end
        end
      end
    end

    def get_exchange_card_wallet
      @exchange = Ddt::WalletActions::Exchange.new
      @wallet = @base_user.card_wallet
      render layout: "ddt/layouts/backend/user"
    end

    def exchange_card_wallet
      @wallet = @base_user.card_wallet
      @exchange = Ddt::WalletActions::Exchange.new(params[:wallet_actions_exchange].merge(wallet: @wallet, operator: current_account))
      respond_to do |format|
        format.html do
          if @exchange.valid?
            @exchange.perform
            redirect_to card_wallet_logs_backend_shop_base_user_path(@current_shop, @base_user), notice: "兑换成功！"
          else
            render 'get_exchange_card_wallet', layout: "ddt/layouts/backend/user"
          end
        end
      end
    end

    def get_exchange_credits_wallet
      @exchange = Ddt::WalletActions::Exchange.new
      @wallet = @base_user.credits_wallet
      render layout: "ddt/layouts/backend/user"
    end

    def exchange_credits_wallet
      @wallet = @base_user.credits_wallet
      @exchange = Ddt::WalletActions::Exchange.new(params[:wallet_actions_exchange].merge(wallet: @wallet, operator: current_account))
      respond_to do |format|
        format.html do
          if @exchange.valid?
            @exchange.perform
            redirect_to credits_wallet_logs_backend_shop_base_user_path(@current_shop, @base_user), notice: "兑换成功！"
          else
            render 'get_exchange_credits_wallet', layout: "ddt/layouts/backend/user"
          end
        end
      end
    end

    def card_wallet_logs
      set_wallet_logs(@base_user.card_wallet)
      @search_form_path = card_wallet_logs_backend_shop_base_user_path(@current_shop, @base_user)
      render 'wallet_logs', layout: "ddt/layouts/backend/user"
    end

    def credits_wallet_logs
      set_wallet_logs(@base_user.credits_wallet)
      @search_form_path = credits_wallet_logs_backend_shop_base_user_path(@current_shop, @base_user)
      render 'wallet_logs', layout: "ddt/layouts/backend/user"
    end

    def recharge_orders
      @q = @base_user.recharge_orders.where(params[:q])
      @recharge_orders = @q.result(distinct: true).paginate(page: params[:page]).query
      render layout: "ddt/layouts/backend/user"
    end

    def get_send_coupon
      @send_coupon_form = Ddt::SendCouponForm.new(
        coupon_version_id: @current_shop.coupon_versions.first.try(:id),
        count: 1,
        base_user_ids: params[:send_user][:send_user_ids].join(','))
    end

    def send_coupon
      @send_coupon_form = Ddt::SendCouponForm.new(params[:send_coupon_form].merge(shop: @current_shop))
      if @send_coupon_form.valid?
        @result = @send_coupon_form.perform
        render :send_coupon
      else
        render :get_send_coupon
      end
    end

    private
      def set_wallet_logs(wallet)
        @wallet = wallet
        collection = wallet.wallet_logs
        @q = collection.ransack(params[:q])
        @wallet_logs = @q.result.paginate(page: params[:page])
      end

      def set_base_user
        @base_user = @current_shop.base_users.find(params[:id])
      end

      def base_user_params
        params.require(:base_user).permit(:name, :phone, :orders_count, :is_blocked, :total_amount, :type,
          :last_latitude, :last_longitude, :last_location_label, :last_location_time,
          :unique_user_id)
      end
  end
end
