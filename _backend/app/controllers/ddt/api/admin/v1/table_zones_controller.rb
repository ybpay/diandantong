module Ddt
  module Api
    module Admin
      module V1
        class TableZonesController < BaseController
          before_action :set_branch
          before_action :set_table_zone, only: [:show, :update, :destroy]

          def index
            table_zones = @branch.table_zones.ransack(params[:q]).result
            render_paginated(table_zones)
          end

          def show
            render_resource(@table_zone, serializer: ->(tz) { tz.as_json(include: [:tables]) })
          end

          def create
            table_zone = @branch.table_zones.build(table_zone_params)
            if table_zone.save
              render_resource_created(table_zone)
            else
              render_errors(table_zone.errors)
            end
          end

          def update
            if @table_zone.update(table_zone_params)
              render_resource(@table_zone)
            else
              render_errors(@table_zone.errors)
            end
          end

          def destroy
            @table_zone.destroy
            render_empty_success(message: "餐区已删除")
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id]) if params[:branch_id]
          end

          def set_table_zone
            scope = @branch ? @branch.table_zones : current_shop.table_zones
            @table_zone = scope.find(params[:id])
          end

          def table_zone_params
            params.require(:table_zone).permit(
              :name, :min_reservation_price, :branch_id,
              :tables_count_for_reservation, :reservation_price,
              :reservation_price_percent, :weixin_ban_product_ids_string,
              :webpos_ban_product_ids_string, :ban_selfpay
            )
          end
        end
      end
    end
  end
end
