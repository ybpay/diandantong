module Ddt
  module Api
    module V1
      module Backend
        class TablesController < Ddt::Api::V1::BaseController
          before_action :set_branch
          before_action :set_table, only: [:show, :update, :destroy, :current_order, :enable_qr_code, :disable_qr_code, :regenerate_qr_code]

          def index
            tables = @branch.tables.includes(:qr_code_scene).ransack(params[:q]).result
            render_paginated(tables)
          end

          def show
            render_resource(@table)
          end

          def create
            table = @branch.tables.build(table_params)
            if table.save
              render_resource_created(table)
            else
              render_errors(table.errors)
            end
          end

          def update
            if @table.update(table_params)
              render_resource(@table)
            else
              render_errors(@table.errors)
            end
          end

          def destroy
            @table.destroy
            render_empty_success(message: "桌台已删除")
          end

          def current_order
            order = @table.current_order
            render_resource(order)
          end

          def enable_qr_code
            @table.enable_qr_code
            render_resource(@table)
          end

          def disable_qr_code
            @table.disable_qr_code
            render_resource(@table)
          end

          def regenerate_qr_code
            @table.regenerate_qr_code
            render_resource(@table)
          end

          def batch_create
            form = Ddt::BatchCreateTableForm.new(
              batch_params.merge(branch: @branch)
            )
            if form.valid?
              form.perform
              render_empty_success(message: "批量创建成功")
            else
              render_errors(form.errors)
            end
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end

          def set_table
            @table = @branch.tables.find(params[:id])
          end

          def table_params
            params.require(:table).permit(:name, :table_zone_id, :capacity, :position)
          end

          def batch_params
            params.require(:batch_create_table_form).permit(:start_name, :count, :table_zone_id, :capacity)
          end
        end
      end
    end
  end
end
