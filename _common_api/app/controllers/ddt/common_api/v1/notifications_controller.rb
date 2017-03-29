module Ddt
  module CommonApi
    module V1
      class NotificationsController < V1::BaseController

        def pull
          pull_at = params[:pull_at] || @current_account.notification_pulled_at
          pull_at = 3.days.ago if pull_at.nil?

          query = Ddt::AppNotificationCache
                       .where(account_id: @current_account.id)
          .where('created_at > ?', pull_at.in_time_zone)
          .order('created_at asc')
          .limit(21)
          
          @notifications = query[0..19]
          @count = query.length
          


          if @notifications.size > 0
            last_pulled_at = @notifications.last.created_at
            if @current_account.notification_pulled_at.nil? || last_pulled_at > @current_account.notification_pulled_at
              @current_account.update!(notification_pulled_at: last_pulled_at)
            end
          end

          if @error_message.present?
            render json: {errors: @error_message}, status: :bad_request
          else
            render json: {
              count: @count,
              result: @notifications.map{|nc| {id: nc.id, message: nc.message}}
            }
          end
        end
      end
    end
  end
end
