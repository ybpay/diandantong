module Ddt
  module Backend
    module Shop
      class PayMethodsController < ::Ddt::Backend::BaseController
        check_permission :shop, :pay_method
        layout 'ddt/layouts/backend/shop'
        before_action :set_pay_method, only: [:show, :edit, :update, :destroy, :change_position]
        def index
          @pay_methods = @current_shop.pay_methods
          respond_to do |format|
            format.html
            format.json {
              render :json => @pay_methods.map(&:select_json)
            }
          end
        end

        def show

        end

        def new
          @pay_method = @current_shop.pay_methods.build
        end

        def create
          @pay_method = @current_shop.pay_methods.build(pay_method_params)
          if @pay_method.save
            redirect_to [:backend, @current_shop, :pay_methods]
          else
            render :new
          end
        end

        def edit

        end

        def update
          if @pay_method.update(pay_method_params)
            redirect_to [:backend, @current_shop, :pay_methods]
          else
            render :edit
          end
        end

        def destroy
          if @pay_method.builtin?
            redirect_to [:backend, @current_shop, :pay_methods], notice: '内建方法不能被删除'
          else
            @pay_method.destroy
            redirect_to [:backend, @current_shop, :pay_methods]
          end
        end

        def change_position
          @pay_method.change_position(params[:position])
          respond_to do |format|
            format.js { render :reset }
          end
        end

        private
        def pay_method_params
          params.require(:pay_method).permit(:name, :code, :enable, :percent_of_actual, :enable_negative,
            :support_delivery, :support_eat_in_hall, :support_fastfood, :support_reservation, :support_groupon, :support_recharge, :support_payment)
        end

        def set_pay_method
          @pay_method = @current_shop.pay_methods.find(params[:id])
        end
      end
    end
  end
end
