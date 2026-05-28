module Ddt
  module Api
    module Admin
      module V1
        class TablesController < BaseController
          before_action :set_table, only: [:show, :update, :destroy]

          def index
            tables = scope.includes(:qr_code_scene).ransack(params[:q]).result
            render_paginated(tables)
          end

          def show
            render_resource(@table)
          end

          def create
            table = scope.build(table_params)
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

          private

          def scope
            if params[:branch_id]
              current_shop.branches.find(params[:branch_id]).tables
            elsif params[:zone_id]
              Ddt::TableZone.find(params[:zone_id]).tables
            else
              Ddt::Table.joins(:branch).where(branches: { shop_id: current_shop.id })
            end
          end

          def set_table
            @table = scope.find(params[:id])
          end

          def table_params
            params.require(:table).permit(:name, :table_zone_id, :capacity, :position)
          end
        end
      end
    end
  end
end
