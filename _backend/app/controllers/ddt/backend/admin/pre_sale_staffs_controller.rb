#encoding: utf-8
module Ddt
  module Backend
    class Admin::PreSaleStaffsController < Ddt::Backend::BaseAdminController
      before_action :set_pre_sale_staff, only: [:show, :edit, :update]
      def index
        @pre_sale_staffs = Ddt::PreSaleStaff.all.paginate(page: params[:page], :per_page => 25)
      end

      def show
      end

      def new

      end

      def create
        @pre_sale_staff = Ddt::PreSaleStaff.new(pre_sale_staff_params)
        if @pre_sale_staff.save
          redirect_to [:backend, :pre_sale_staffs]
        else
          render :new
        end
      end

      def edit

      end

      def update
        if @pre_sale_staff.update(pre_sale_staff_params)
          redirect_to [:backend, :pre_sale_staffs]
        else
          render :edit
        end
      end

      def destroy
        @pre_sale_staff.destroy
        redirect_to [:backend, :pre_sale_staffs]
      end

      private
      def pre_sale_staff_params
        params.require(:pre_sale_staff).permit(:name, :phone, :qq, :email, :shop_ids_string)
      end

      def set_pre_sale_staff
        @pre_sale_staff = Ddt::PreSaleStaff.find(params[:id])
      end
    end
  end
end
