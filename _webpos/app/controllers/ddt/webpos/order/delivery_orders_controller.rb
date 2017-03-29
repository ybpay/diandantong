module Ddt
  module Webpos
    module Order
      class DeliveryOrdersController < Webpos::BaseController
        include Webpos::BaseOrderController
        include Webpos::BaseOrderChangeController
        check_permission :branch, :delivery_order, {
          create: :create,
          assign_delivery_man: :assign_delivery_man
        }, only: [:create, :assign_delivery_man]
        def create
          ActiveRecord::Base.transaction do
            @user = @current_shop.phone_users.where(:phone => params[:user][:phone]).first_or_create
            if @user.errors.present?
              render json: {error: @user.errors.full_messages }, status: :bad_request
              return
            end
            @address = @user.addresses.where({
              name:    params[:user][:name],
              building: params[:user][:building],
              room_no: params[:user][:room_no],
              phone:   params[:user][:phone]
            }).first

            if @address.present?
              if params[:user][:latitude] && params[:user][:longitude]
                @address.update!(latitude: params[:user][:latitude], longitude: params[:user][:longitude])
              end
            else
              @address = @user.addresses.build({
                name:    params[:user][:name],
                building: params[:user][:building],
                room_no: params[:user][:room_no],
                phone:   params[:user][:phone],
                latitude: params[:user][:latitude],
                longitude: params[:user][:longitude]
              })
              if @address.valid?
                @address.save!
              else
                render json: {error: @address.errors.full_messages }, status: :bad_request
                return
              end
            end
            @shipment = Shipment.new(
                address: @address,
                delivery_zone_id: params[:user][:delivery_zone_id],
                delivery_man_id:  params[:user][:delivery_man_id],
                delivery_time_id: params[:user][:delivery_time_id],
                delivery_date:    params[:user][:delivery_date]
              )
            line_itemables = OrderService::LineItemable.init_list(params[:cart][:line_items_attributes])
            form_contentables = OrderService::FormContentable.init_list(params.fetch(:order,{}).fetch(:form_contents, []))
            @cart = OrderService::Cart::Delivery.new(base_cart_params.merge(
                line_itemables: line_itemables,
                form_contentables: form_contentables,
                user: @user,
                shipment: @shipment,
                note: params[:user][:note],
              ))
            @order = @cart.place
            if @order.present?
              if @order.is_local_printed
                render json: { bill: order_bill(@order), id: @order.id, type_str: @order.type_str, branch_id: @order.branch_id }
              else
                render :show
              end
            else
              render json: {errors: @cart.errors.full_messages}, status: :bad_request
              raise ActiveRecord::Rollback
            end
          end
        end

        def assign_delivery_man
          @order.assign_delivery_man(params[:delivery_man_id])
          render :show
        end
      end
    end
  end
end
