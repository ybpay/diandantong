module Ddt
  class Backend::PrinterCodesController < Backend::BaseController
  	before_action :valid_count, only: [:create, :update]
  	def index
  	  @printer_codes = @current_shop.printer_codes
  	end

   	def create
   	  shop_name = current_shop.name || ''
   	  result = Ddt::Printer::Api.send_post('/printers/create_normal',{name: shop_name, shop_id: current_shop.id}).try(:first)
   	  if result.present? && result[:shop_id] == current_shop.id
   	    @printer_code = current_shop.printer_codes.create(code: result[:printer_code], secret: result[:secret])
        respond_to do |format|
   	      format.html { redirect_to backend_shop_printer_codes_path }
          format.json {render json: {id: @printer_code.id, code: @printer_code.code}}
        end
   	  else
   	  	flash[:error] = "数据不正确，获取失败"
        respond_to do |format|
   	      format.html { redirect_to backend_shop_printer_codes_path }
          format.json {render json: {errors: "数据不正确，获取失败"}, status: :bad_request}
        end
   	  end
   	end

   	def bind
   	  result = Ddt::Printer::Api.send_post('/printers/bind',{shop_id: current_shop.id, printer_code: printer_code_params[:code], secret: printer_code_params[:secret]})
   	  if result[:errors].nil?
   	  	current_shop.printer_codes.create(code: printer_code_params[:code], secret: printer_code_params[:secret])
   	  	redirect_to backend_shop_printer_codes_path, notice: "认领成功"
   	  else
   	  	flash[:error] = result[:errors].inspect
   	    redirect_to backend_shop_printer_codes_path
   	  end
   	end

    private

   	def valid_count
   	     # 判断是否为商圈版
   	  if current_shop.shop_type.include?('o') && current_shop.printer_codes.count >= (2 * current_shop.max_branches_limit)
   	  	flash[:error] = "您的授权码平均每个门店不得超过2个"
   	  	redirect_to backend_shop_printer_codes_path
   	  elsif current_shop.printer_codes.count >= (10 * current_shop.max_branches_limit)
   	  	flash[:error] = "您的授权码平均每个门店不得超过10个"
   	  	redirect_to backend_shop_printer_codes_path
   	  end
   	end

    def printer_code_params
      params.require(:printer_code).permit(:code, :secret)
    end
   end
end