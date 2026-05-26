module Ddt
  module Api
    module V1
      module Webpos
        class ShiftsController < Ddt::Api::V1::BaseController
          before_action :set_branch

          def current
            shift = @branch.shifts.where(closed_at: nil).order(created_at: :desc).first
            if shift
              render_resource(shift)
            else
              render json: { data: nil, meta: { message: "当前无班次" } }
            end
          end

          def open
            shift = @branch.shifts.build(opened_by: current_account.id)
            if shift.save
              render_resource_created(shift)
            else
              render_errors(shift.errors)
            end
          end

          def close
            shift = @branch.shifts.find(params[:id])
            if shift.update(closed_at: Time.current, closed_by: current_account.id)
              render_resource(shift)
            else
              render_errors(shift.errors)
            end
          end

          private

          def set_branch
            @branch = current_shop.branches.find(params[:branch_id])
          end
        end
      end
    end
  end
end
