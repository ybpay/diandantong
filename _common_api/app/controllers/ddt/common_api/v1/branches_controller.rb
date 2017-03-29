module Ddt
  module CommonApi
    module V1
      class BranchesController < V1::BaseController
        def index
          @branches = paginate current_account.managed_branches.valid_now.ransack(params[:q]).result(distinct: true)
          fresh_when(@branches)
        end

        def show
          fresh_when(@current_branch)
        end

        def cache_versions
        end

        def update
          params = branch_params
          accessable_ssid_for_app = params.delete(:accessable_ssid_for_app)
          if @current_branch.update(params.merge(eat_in_hall_setting_attributes: {
              id: @current_branch.eat_in_hall_setting.id,
              accessable_ssid_for_app: accessable_ssid_for_app
            }))
            render :show
          else
            render json: {errors: @current_branch.errors.full_messages}, status: :bad_request
          end
        end

        def update_cs_data
          cs_helper = Ddt::CsHelper.new(branch_id: @current_branch.id, start_at: params[:start_at], end_at: params[:end_at])
          if cs_helper.valid?
            cs_helper.perform
            render json: {ok: true}
          else
            render json: {errors: cs_helper.errors.full_messages}, status: :bad_request
          end
        end

        def open_shift
          if @current_branch.open_shift(current_account, params[:pre_cash_amount])
            @current_branch.reload
            render :show
          else
            render json: { errors: @current_branch.errors.full_messages }, status: :bad_request
          end
        end

        def close_shift
          if @current_branch.close_shift
            @current_branch.reload
            render :show
          else
            render json: { errors: @current_branch.errors.full_messages }, status: :bad_request
          end
        end

        def get_shift
          @shift = @current_branch.current_shift
          if @shift.present?
            @shift.update_amount
          else
            render json: { errors: "当前店铺没有开班" }, status: :bad_request
          end
        end


        private
        def branch_params
          params.require(:branch).permit(:name, :open_on_monday, :open_on_tuesday, :open_on_wednesday, :open_on_thursday,
            :open_on_friday, :open_on_saturday, :open_on_sunday, :phone, :address, :notice, :accessable_ssid_for_app, :note_placeholder)
        end
      end
    end
  end
end
