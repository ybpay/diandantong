# encoding: utf-8
module Ddt
  class Backend::Admin::SalesEmailsController < Backend::BaseAdminController

    def index
      @q = Ddt::SalesEmail.ransack(params[:q])
      @sales_emails = @q.result(distinct: true).paginate(page: params[:page])
    end

    def new
      @sales_email = Ddt::SalesEmail.new
    end

    def create
      @sales_email = Ddt::SalesEmail.new(sales_email_params)
      if @sales_email.save
        redirect_to [:backend, :sales_emails]
      else
        render :new
      end
    end

    def destroy
      @sales_email = Ddt::SalesEmail.find(params[:id])
      @sales_email.destroy
      redirect_to [:backend, :sales_emails]
    end

    private
    def sales_email_params
      params.require(:sales_email).permit(:email)
    end

  end
end
