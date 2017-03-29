module Ddt
  module OrderService
    module Cart
      class Reservation < Cart::Base
        attr_accessor :reservation_info, :prepayment_type,
                      :reservation_table_zone_name, :reservation_table_name,
                      :reservation_date, :reservation_time_point_display,
                      :reservation_name, :reservation_phone, :reservation_gender

        acts_as_type :prepayment_type, [:prepay_for_table, :prepay_for_order], %W[预订订座预付 预订下单预付]
        delegate :reservation_time_point, :table_zone, to: :reservation_info
        acts_as_type :reservation_gender, [:male, :female], %W[先生 女士]

        def init_info(params={})
          @reservation_info = params.fetch(:reservation_info, ReservationInfo.new)
          cache_reservation_info
          update_prepayment_type(params.fetch(:prepayment_type, :prepay_for_order))
        end

        def after_place(order, operator)
          reservation_info.reservation_order = order
          reservation_info.save!
          super
        end

        def evaluate_promotion?
          false
        end

        def amount_for_pay
          if self.is_prepay_for_table?
            total
          elsif self.is_prepay_for_order?
            if reservation_info.table_zone.present?
              total * (reservation_info.table_zone.try(:reservation_price_percent) / 100.0)
            else
              total
            end
          end
        end

        def to_options
          options = { }
          [ :prepayment_type, :reservation_table_zone_name, :reservation_table_name,
            :reservation_date, :reservation_time_point_display,
            :reservation_name, :reservation_phone, :reservation_gender].each{|key| options[key] = self.send(key)}
          super.merge(options)
        end

        def default_pay_method
          :pay_on_arrive
        end

        concerning :Validation do
          included do
            validate :check_reservation_info
            validate :check_item_count, if: :is_prepay_for_order?
          end

          def check_reservation_info
            if self.reservation_info.invalid?
              self.errors[:base] << "预订日期不能为空" if self.reservation_info.errors[:reservation_date].present?
              self.errors[:base] << "预订桌台区域不能为空" if self.reservation_info.errors[:table_zone].present?
              self.errors[:base] << "预订时间点不能为空" if self.reservation_info.errors[:reservation_time_point].present?
              self.errors[:base] << "预订电话格式不正确" if self.reservation_info.errors[:phone].present?
            end
          end
        end

        concerning :SessionStore do
          included do
            def self.cart_options_from_session(session)
              prepayment_type = session.fetch(:prepayment_type, nil)
              reservation_date = session[:reservation_date].present? ? Date.parse(session[:reservation_date]) : nil
              reservation_time_point = ReservationTimePoint.find_by(id: session[:reservation_time_point_id])
              reservation_info = ReservationInfo.new(
                name: session[:reservation_name],
                phone: session[:reservation_phone],
                gender: session[:reservation_gender],
                reservation_date: reservation_date,
                reservation_time_point: reservation_time_point,
              )
              super.merge({
                prepayment_type: prepayment_type,
                reservation_info: reservation_info
              })
            end
          end

          def to_session
            super.merge({
              prepayment_type: prepayment_type,
              reservation_name: reservation_name,
              reservation_phone: reservation_phone,
              reservation_gender: reservation_gender,
              reservation_date: reservation_date.try(:strftime, "%F"),
              reservation_time_point_id: reservation_info.reservation_time_point_id,
            })
          end
        end

        def update_reservation_info(params={})
          reservation_info.name                      = params[:name]                      if params[:name].present?
          reservation_info.phone                     = params[:phone]                     if params[:phone].present?
          reservation_info.gender                    = params[:gender]                    if params[:gender].present?
          reservation_info.reservation_date          = params[:reservation_date]          if params[:reservation_date].present?
          reservation_info.reservation_time_point_id = params[:reservation_time_point_id] if params[:reservation_time_point_id].present?
          reservation_info.reservation_time_point    = params[:reservation_time_point]    if params[:reservation_time_point].present?
          reservation_info.set_from_reservation_time_point
          cache_reservation_info
        end

        def update_prepayment_type(prepayment_type)
          self.prepayment_type = prepayment_type
          adjustments.reservation_table_price.destroy_all
          if is_prepay_for_table?
            adjust(reason: :reservation_table_price, source: reservation_info.table_zone) if reservation_info.table_zone.present?
            clear
            update_discount
          end
        end


        def reservation_date_str
          reservation_date.try(:strftime, "%F")
        end
        alias_method :reservation_time_point_str, :reservation_time_point_display

        def pay_method_blacklist
          [:pay_on_receive]
        end

        private
        def cache_reservation_info
          self.reservation_table_zone_name    = reservation_info.table_zone_name
          self.reservation_table_name         = reservation_info.table_name
          self.reservation_date               = reservation_info.reservation_date
          self.reservation_time_point_display = reservation_info.time_point_display
          self.reservation_name               = reservation_info.name
          self.reservation_phone              = reservation_info.phone
          self.reservation_gender             = reservation_info.gender
        end

      end
    end
  end
end