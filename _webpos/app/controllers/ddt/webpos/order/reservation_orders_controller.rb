module Ddt
  module Webpos
    module Order
      class ReservationOrdersController < Webpos::BaseController
        include Webpos::BaseOrderController
        check_permission :branch, :reservation_order, { create: :create, change_to_eat_in_hall: :change_to_eat_in_hall, bind_table: :bind_table, edit_reservation_info: :edit_reservation_info}, only: [:create,:change_to_eat_in_hall,:bind_table,:edit_reservation_info]
        def create
          @table = @current_branch.tables.find(params[:table_id])
          reservation_info = ReservationInfo.new(
              name: params[:name],
              phone: params[:phone],
              gender: params[:gender],
              table_id: params[:table_id],
              reservation_date: params[:reservation_date],
              reservation_time_point_id: params[:reservation_time_point_id],
            )
          cart = OrderService::Cart::Reservation.new(base_cart_params.merge(
            reservation_info: reservation_info,
            table: @table,
            note: params[:note],
            prepayment_type: :prepay_for_table,
            pay_method: :pay_on_arrive,
          ))
          @order = cart.place
          if @order
            if @order.is_local_printed
              render json: { bill: order_bill(@order), id: @order.id }
            else
              render :show
            end
          else
            render :json => { errors: cart.errors.full_messages }, status: :bad_request
          end
        end

        def change_to_eat_in_hall
          if @order.change_to_eat_in_hall(params[:table_id], note: params[:note])
            render :show
          else
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

        def bind_table
          @table = @current_branch.tables.find(params[:table_id])
          if @order.bind_table(@table)
            render :show
          else
            render json: { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

        def edit_reservation_info
          if @order.update_reservation_info(params.permit(:name, :phone, :gender, :note))
            render :json => {}
          else
            render :json => { errors: @order.errors.full_messages }, status: :bad_request
          end
        end

        private
        def order_params
          params.require(:order).permit(:name, :phone, :gender, :note)
        end
      end
    end
  end
end