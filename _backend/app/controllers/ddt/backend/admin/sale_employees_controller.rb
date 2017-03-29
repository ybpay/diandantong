#encoding: utf-8
module Ddt
  module Backend
    class Admin::SaleEmployeesController < Ddt::Backend::BaseAdminController
      before_action :set_sale_employee, only: [:show, :edit, :update, :statistic]
      def index
        @sale_employees = Ddt::SaleEmployee.all.paginate(page: params[:page], :per_page => 25)
      end

      def show
        @q = @sale_employee.shops.ransack(params[:q])
        @shops = @q.result(distinct: true).paginate(page: params[:page])
      end

      def statistic
        respond_to do |format|
          format.html
          format.js
        end
      end

      def new
        @sale_employee = Ddt::SaleEmployee.new
      end

      def create
        @sale_employee = Ddt::SaleEmployee.new(sale_employee_params)
        if @sale_employee.save
          redirect_to [:backend, :sale_employees]
        else
          render :new
        end
      end

      def edit

      end

      def update
        if @sale_employee.update(sale_employee_params)
          redirect_to [:backend, :sale_employees]
        else
          render :edit
        end
      end

      def destroy
        @sale_employee.destroy
        redirect_to [:backend, :sale_employees]
      end

      private
      def sale_employee_params
        params.require(:sale_employee).permit(:name, :phone, :qq, :email, :shop_ids_string, :agent_ids_string)
      end

      def set_sale_employee
        @sale_employee = Ddt::SaleEmployee.find(params[:id])
      end
    end
  end
end
