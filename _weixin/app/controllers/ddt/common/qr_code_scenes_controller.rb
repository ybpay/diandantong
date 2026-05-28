#encoding: utf-8
module Ddt
  class Common::QrCodeScenesController < CommonApplicationController
    before_action :set_qr_code_scene, only: [:show]
    skip_before_action :validate_user_info
    skip_before_action :set_current_shop
    skip_before_action :check_current_shop

    def show
      debugger
      unless ddt_app?
        if !@qr_code_scene.is_enable?
          render plain: '啊哦！商家把我关闭了，以后再扫我吧 :)'
          return
        end
        validate_user_info
        @qr_code_scene.scan_by(@current_user)
        if @qr_code_scene.preferred_redirect_url.present?
          redirect_to @qr_code_scene.preferred_redirect_url
        elsif @qr_code_scene.owner.present?
          if @qr_code_scene.owner.is_a? OrderService::Order::Base
            redirect_to request_url(request, @qr_code_scene.owner.weixin_bind_path)
          elsif @qr_code_scene.owner.is_a? GuestQueue
            Ddt::OrderItemable::Adapter.new(
              store_type: 'for_pre_order',
              guest_queue_id: @qr_code_scene.owner.id
            ).attach(session)
            redirect_to request_url(request, @qr_code_scene.owner.weixin_bind_path)
          else
            @owner = @qr_code_scene.owner
            if @owner.allow_scan?(@current_user)
              if @owner.is_a? Ddt::Table
                @owner.scan(@current_user)
                Ddt::OrderItemable::Adapter.new(
                  store_type: 'for_merge_order',
                  table_id: @owner.id
                ).attach(session)
              else
                @owner.try(:scan)
              end
              redirect_to request_url(request, "#{weixin_shop_path(@current_shop)}#{@owner.weixin_path}")
            else
              flash[:error] = [@qr_code_scene.errors.full_messages, @owner.errors.full_messages].flatten.join(',')
              redirect_to request_url(request, weixin_shop_path(@current_shop, anchor: "/?error=#{flash[:error]}"))
            end
          end
        end
      else
        result = {
            owner_id: @qr_code_scene.owner_id,
            owner_type: @qr_code_scene.owner_type.demodulize.underscore
        }

        #
        # 对 App 获取数据进行优化，通过 Header 把 AccessToken 传过来做获取数据的权限检查
        # 以此做最低限度的安全性检查
        #
        # XXX 这里稍稍破坏了模块依赖关系，以后想办法修复
        #
        with_owner = request.headers['With-Owner']
        token = request.headers['Access-Token']
        if with_owner.present? and token.present?
          access_token = Ddt::AccessToken.get(token)
          if access_token.present?
            account = access_token.account
            if account.can?(:branch, result[:owner_type].to_sym, :show)
              owner = @qr_code_scene.owner
              entity_class = "Ddt::OAPI::Entities::#{result[:owner_type].camelize}".constantize
              entity = entity_class.represent(owner)
              result[:owner] = entity.serializable_hash
            end
          end
        end

        render :json => {
                   code: 0,
                   message: 'ok',
                   result: result
               }
      end
    end

   private
    def set_qr_code_scene
      @qr_code_scene = Ddt::QrCodeScene.friendly.find(params[:id])
      @current_shop = @qr_code_scene.shop if @qr_code_scene.present?
    end

    def request_url(request, path)
      unless path.starts_with? "http"
        "#{request.protocol}#{Rails.application.default_url_options[:host]}#{path}"
      else
        path
      end
    end
  end
end
