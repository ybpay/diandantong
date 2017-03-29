# encoding: utf-8
module Ddt
  class Weixin::Order::InvitationOrdersController < WeixinApplicationController
    before_action :set_order, only: [:show, :agree, :disagree]

    def show
      unless @is_my_order
        rc = @order.invitation_order_guests.find_by(guest_id: @current_user.id)
        if rc.present?
          @opinion = rc.agree
        else
          @opinion = nil
        end
      end
    end

    def agree
      unless @is_my_order
        @invitation_order_guest = @order.invitation_order_guests.where(guest_id: @current_user.id).first_or_create!(:agree=>true)
        @invitation_order_guest.accept_invitation
        render :json => @invitation_order_guest
      else
        render json: {errors: ['you are not guest']}, status: :bad_request
      end
    end

    def disagree
      unless @is_my_order
        @invitation_order_guest = @order.invitation_order_guests.where(guest_id: @current_user.id).first_or_create!(agree: false)
        @invitation_order_guest.reject_invitation
        render :json => @invitation_order_guest
      else
        render json: {errors: ['you are not guest']}, status: :bad_request
      end
    end

    private
    def set_order
      if params[:wechat_share_record_trigger_timestamp].present?
        # 从分享进入
        wechat_share_record = @current_shop.wechat_share_records.find_by_trigger_timestamp(params[:wechat_share_record_trigger_timestamp])
        if wechat_share_record.present?
          @order = Ddt::OrderService::Order::Reservation.find(params[:id])
          @is_my_order = (@order.user == @current_user)
        else
          render json: {errors: ['cannot get share record']}, status: :bad_request
        end
      else
        # 正常途径进入，只有订单用户才进入
        @order_user = @current_user
        @order = @current_user.reservation_orders.find(params[:id])
        @is_my_order = true
      end
    end

  end
end
