module Ddt
  class Weixin::ExchangeCodesController < WeixinApplicationController
    respond_to :json
    before_action :set_exchange_code, only: [:show, :get_permissions, :exchange, :get_qrcode]
    def show
      render :json => {
        code:  @exchange_code.code.insert(4, " ").insert(9, " "),
        state: @exchange_code.state,
        exchanged_at: @exchange_code.exchanged_at,
        state_name: @exchange_code.state_name,
        exchange_detail: @exchange_code.exchangeable.exchange_detail,
        name: @exchange_code.exchangeable.try(:abstract_coupon_version).try(:name),
        expired_at: @exchange_code.exchangeable.try(:abstract_coupon_version).try(:usable_expires_at_formated)
      }
    end

    def exchange
      @exchange_code.exchange if @current_user.is_account_user?
      render :json => {}
    end

    def get_permissions
      permissions = []
      if @current_user == @exchange_code.exchangeable.user
        permissions += [:get_qrcode, :show]
      end
      if @current_user.is_account_user? && @current_user.account_user.managed_branches.any?{|branch| @exchange_code.exchangeable.can_exchange?(branch)}
        permissions += [:exchange, :show]
      end
      render :json => { permissions: permissions }
    end

    def get_qrcode
      render :json => {
        url: @exchange_code.get_qr_code.url.url,
        qrcode_html: @exchange_code.code_html[:qrcode],
        barcode_html: @exchange_code.code_html[:barcode],
      }
    end

    private
    def set_exchange_code
      @exchange_code = @current_shop.exchange_codes.find(params[:id])
    end
  end
end
