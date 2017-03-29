module Ddt
  class Weixin::ShopsController < WeixinApplicationController
    before_filter :set_wx_config, only: [:show, :my, :cart, :order, :queue]
    before_filter :record_visit, only: [:show, :my, :cart, :order, :queue]

    def show

      # 以下三个判断可改成钩子实现

      if "/nearby_branch" == params[:_ng_path] && @current_shop.multi_branch?
        nearby_branch = Ddt::Branch.where(shop: @current_shop).open_on_today.valid_now.by_distance(origin: @current_user).limit(1).first
        ng_path = nearby_branch.present? ? "/branches/#{nearby_branch.id}" : "/"
        redirect_to action: :show, params: {_ng_path: ng_path}
        return
      end

      if params[:act] == 'invoke_wechatpay_v3'
        @order = @current_user.orders.find(params[:order_id])
        @payment = @order.current_payment if @order.pay_method == 'wechatpay'
        @data = @payment.process(request)['data'] if @payment.present?
        @callback_url = "http://#{request.host}:#{request.port}/#{@order.weixin_after_pay_path}"
        return render :invoke_wechatpay_v3, layout: 'ddt/layouts/empty'
      end

      if [nil, "/"].include?(params[:_ng_path]) && params[:_shake_around].blank?
        @one_pages = @current_shop.one_pages
        if @one_pages.present? && (cookies[:shown_tutorial] != 'yes' || params[:act] == 'show_tutorial')
          show_tutorial
          return
        end
      end

      @shop = @current_shop
      @shop_json = render_to_string( :template => 'ddt/weixin/shops/show.json.jbuilder')
      @user_json = render_to_string( :template => 'ddt/weixin/user/users/show.json.jbuilder')
      @search_words_json = render_to_string(:template => 'ddt/weixin/shops/search_word.json.jbuilder')

      respond_to do |format|
        format.html {
          render :show, layout: 'ddt/layouts/main'
        }
      end
    end

    def my
      @shop = @current_shop
      @shop_json = render_to_string( :template => 'ddt/weixin/shops/show.json.jbuilder')
      @user_json = render_to_string( :template => 'ddt/weixin/user/users/show.json.jbuilder')
      @weixin_pages_json = render_to_string( :template => 'ddt/weixin/weixin_pages/index.json.jbuilder')

      respond_to do |format|
        format.html {
          render :show, layout: 'ddt/layouts/my'
        }
      end
    end

    def cart
      @shop = @current_shop
      @shop_json = render_to_string( :template => 'ddt/weixin/shops/show.json.jbuilder')
      @user_json = render_to_string( :template => 'ddt/weixin/user/users/show.json.jbuilder')
      respond_to do |format|
        format.html {
          render :show, layout: 'ddt/layouts/cart'
        }
      end
    end


    def order
      @shop = @current_shop
      @shop_json = render_to_string( :template => 'ddt/weixin/shops/show.json.jbuilder')
      @user_json = render_to_string( :template => 'ddt/weixin/user/users/show.json.jbuilder')
      respond_to do |format|
        format.html {
          render :show, layout: 'ddt/layouts/order'
        }
      end
    end

    def queue
      @shop = @current_shop
      @shop_json = render_to_string( :template => 'ddt/weixin/shops/show.json.jbuilder')
      @user_json = render_to_string( :template => 'ddt/weixin/user/users/show.json.jbuilder')
      respond_to do |format|
        format.html {
          render :show, layout: 'ddt/layouts/queue'
        }
      end
    end

    def manage
      @shop = @current_shop
      @shop_json = render_to_string( :template => 'ddt/weixin/shops/show.json.jbuilder')
      @user_json = render_to_string( :template => 'ddt/weixin/user/users/show.json.jbuilder')
      respond_to do |format|
        format.html {
          render :show, layout: 'ddt/layouts/manage'
        }
      end
    end

    def record_visit
      if params[:wechat_share_record_trigger_timestamp]
        impressionist(@current_shop, message: 'friendcircle',  unique: [:controller_name, :action_name, :session_hash, :user_id])
      else
        impressionist(@current_shop, message: 'wechat',  unique: [:controller_name, :action_name, :session_hash, :user_id])
      end
    end

    private
    def set_wx_config
      request_url = "#{request.protocol}#{Rails.application.default_url_options[:host]}#{request.fullpath}"
      if request.query_string.blank?
        redirect_to "#{request_url}?source=qq.com"
      end
      unless @current_user.wifi_code
        method = @current_shop.wechatpay_method_v336
        if method.try(:active)
          wechat_account = @current_shop.wechat_accounts.find_by(gonghao_open_id: method.preferred_gonghao_open_id).try(:first)
        end
        wechat_account = @current_shop.primary_wechat_account if wechat_account.blank?
        if wechat_account.present?
          timestamp = DateTime.now.to_i
          nonceStr = SecureRandom.uuid.to_s
          @wx_config = {
            wxConfigAppId: wechat_account.account_appid,
            wxConfigTimestamp: timestamp,
            wxConfigNonceStr: nonceStr,
            wxConfigSignature: WeixinApi.jsapi_ticket_signature(wechat_account.get_jsapi_ticket, nonceStr, timestamp, request_url)
          }
        end
      end
    end

    def show_tutorial
      if @one_pages.present?
        cookies[:shown_tutorial] = {:value => 'yes', :expires => 30.minutes.from_now }
        render :tutorial, layout: 'ddt/layouts/empty'
      end
    end

  end
end
