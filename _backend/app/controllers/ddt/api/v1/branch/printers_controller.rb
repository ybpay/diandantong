module Ddt
  module Api
    module V1
      module Backend
        class PrintersController < Ddt::Api::V1::BaseController
          before_action :set_branch

          def index
            printers = @branch.printers.ransack(params[:q]).result
            render json: { data: printers.map(&:as_api_json) }
          end

          def show
            printer = @branch.printers.find(params[:id])
            render_resource(printer)
          end

          def create
            printer = @branch.printers.build(printer_params)
            if printer.save
              render_resource_created(printer)
            else
              render_errors(printer.errors)
            end
          end

          def update
            printer = @branch.printers.find(params[:id])
            if printer.update(printer_params)
              render_resource(printer)
            else
              render_errors(printer.errors)
            end
          end

          def destroy
            printer = @branch.printers.find(params[:id])
            printer.destroy
            render_empty_success(message: "打印机已删除")
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end

          def printer_params
            params.require(:printer).permit(:name, :printer_type, :is_auto_print, :copies, :print_setting_id)
          end
        end
      end
    end
  end
end
