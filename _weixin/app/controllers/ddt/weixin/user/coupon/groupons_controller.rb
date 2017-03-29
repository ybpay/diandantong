module Ddt
  module Weixin
    module User
      module Coupon
        class GrouponsController < WeixinApplicationController
          respond_to :json
          before_action :set_collection, only: [:index]
          before_action :set_groupon, only: [:show, :apply_refund, :cancel_apply_refund]
          def index
            @groupons = @collection.paginate(page: params[:page], per_page: params[:per_page] || 8)
          end

          def show
          end

          def apply_refund
            @groupon.apply_refund
            render :show
          end

          def cancel_apply_refund
            @groupon.cancel_apply_refund
            render :show
          end

          private
          def set_collection
            if params[:state]
              case params[:state].to_sym
              when :available then @collection = @current_user.groupons.available
              when :applied   then @collection = @current_user.groupons.applied
              when :expired   then @collection = @current_user.groupons.expired
              when :refund    then @collection = @current_user.groupons.refund
              end
            else
              @collection = @current_user.groupons
            end
          end

          def set_groupon
            @groupon = @current_user.groupons.find(params[:id])
          end
        end
      end
    end
  end
end
