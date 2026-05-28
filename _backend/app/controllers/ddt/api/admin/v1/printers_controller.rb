module Ddt
  module Api
    module Admin
      module V1
        class PrintersController < BaseController
          before_action :set_printer, only: [:show, :update, :destroy]

          def index
            printers = current_shop.printers.ransack(params[:q]).result.distinct
            render_paginated(printers)
          end

          def show
            render_resource(@printer)
          end

          def create
            printer = current_shop.printers.build(printer_params)
            if printer.save
              render_resource_created(printer)
            else
              render_errors(printer.errors)
            end
          end

          def update
            if @printer.update(printer_params)
              render_resource(@printer)
            else
              render_errors(@printer.errors)
            end
          end

          def destroy
            @printer.destroy
            render_empty_success(message: "打印机已删除")
          end

          private

          def set_printer
            @printer = current_shop.printers.find(params[:id])
          end

          def printer_params
            params.require(:printer).permit(:name, :printer_type, :device_sn, :branch_id)
          end
        end
      end
    end
  end
end
