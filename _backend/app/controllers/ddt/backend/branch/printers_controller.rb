module Ddt
  module Backend
    module Branch
      class PrintersController < ::Ddt::Backend::BaseController
        check_permission :branch, :printer, base_permission_actions.merge({[:get_state, :products]=> :show, test_print: :update, clear_records: :update, toggle: :update})
        before_action :set_printer, only: [:edit, :update, :destroy, :test_print, :get_state, :clear_records, :toggle]
        layout "ddt/layouts/backend/branch"
        def index
          @printers = @current_branch.printers
        end

        def new
          @printer = @current_branch.printers.build
          @printer.type = 'Ddt::Printer::Normal'
          @printer.use_scene = 'webpos'
        end

        def create
          @printer = @current_branch.printers.build(printer_params)
          if @printer.save
            redirect_to [:backend, @current_shop, @current_branch, :printers]
          else
            render :new
          end
        end

        def edit
        end

        def update
          if @printer.update(printer_params)
            @printer.touch
            redirect_to [:backend, @current_shop, @current_branch, :printers]
          else
            render :edit
          end
        end

        def destroy
          @printer.destroy
          redirect_to [:backend, @current_shop, @current_branch, :printers]
        end

        def test_print
          begin
            @result = @printer.print('打印测试', 1)
          rescue Exception => e
            logger.error e
            @result = false
          end
          respond_to do |format|
            format.js
          end
        end

        def get_state
          begin
            @state = @printer.get_state
          rescue Exception => e
            logger.error e
            @state = :unknow
          end
          respond_to do |format|
            format.js
          end
        end

        def clear_records
          begin
            @printer.clear_records
            @result = true
          rescue Exception => e
            logger.error e
            @result = false
          end
          respond_to do |format|
            format.js
          end
        end

        def toggle
          @printer.update(enable: !@printer.enable)
        end

        def products
          @printers = @current_branch.printers.use_in_kitchen
          if params[:not_configured].present?
            # collect printer_product_ids
            whitelist = []
            @printers.each do |printer|
              whitelist.concat(printer.white_list_product_ids)
            end
            scope = @current_branch.products.where.not(id: whitelist.uniq)
          elsif params[:multi_configured].present?
            whitelist = []
            @printers.each do |printer|
              whitelist.concat(printer.white_list_product_ids)
            end
            whitelist = whitelist.find_all { |e| whitelist.count(e) > 1 }
            scope = @current_branch.products.where(id: whitelist)
          else
            scope = @current_branch.products
          end
          @q = scope.ransack(params[:q])
          @products = @q.result(distinct: true).paginate(page: params[:page])
          respond_to do |format|
            format.html
          end
        end

        private
        def printer_params
          params.require(:printer).permit(:name, :type, :number, :times, :member_code, :api_key, :phone, :copy_number, :enable, :token, :is_print_all,:print_one_by_one, :print_per_product, :use_scene, :print_spec, :product_ids_string, :category_ids_string, :table_ids_string, :ban_product_ids_string)
        end

        def set_printer
          @printer = @current_branch.printers.find(params[:id])
        end
      end
    end
  end
end
