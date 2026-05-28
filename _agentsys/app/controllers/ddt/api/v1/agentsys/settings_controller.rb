module Ddt
  module Api
    module V1
      module Agentsys
        class SettingsController < BaseController
          def show
            agent = current_agent
            settings = agent.notification_settings || default_notification_settings
            render json: {
              name: agent.name,
              email: agent.email,
              phone: agent.phone,
              agent_level: agent.agent_type_label,
              managed_merchants: agent.shops.count,
              notifications: {
                expirationReminder: settings["expiration_reminder"],
                newMerchantNotify: settings["new_merchant_notify"],
                renewalNotify: settings["renewal_notify"],
                remindDays: settings["remind_days"]
              }
            }
          end

          def update_profile
            if current_agent.update(profile_params)
              render json: { data: { message: "保存成功" } }
            else
              render json: { errors: [{ status: 422, title: "保存失败", detail: current_agent.errors.full_messages.join(", "), code: "VALIDATION_ERROR" }] }, status: :unprocessable_entity
            end
          end

          def update_password
            unless current_agent.valid_password?(params[:current_password])
              render json: { errors: [{ status: 422, title: "当前密码错误", code: "INVALID_PASSWORD" }] }, status: :unprocessable_entity
              return
            end

            if params[:new_password].present? && params[:new_password].length >= 6
              current_agent.update(password: params[:new_password], password_confirmation: params[:new_password])
              render json: { data: { message: "密码修改成功" } }
            else
              render json: { errors: [{ status: 422, title: "密码至少6位", code: "VALIDATION_ERROR" }] }, status: :unprocessable_entity
            end
          end

          def update_notifications
            settings = notification_params.to_h
            current_agent.update(notification_settings: settings)
            render json: { data: { message: "保存成功" } }
          end

          private

          def default_notification_settings
            {
              "expiration_reminder" => true,
              "new_merchant_notify" => true,
              "renewal_notify" => true,
              "remind_days" => 30
            }
          end

          def profile_params
            params.permit(:name, :phone, :company_name, :wechat_introduce_url, :qq)
          end

          def notification_params
            params.permit(:expiration_reminder, :new_merchant_notify, :renewal_notify, :remind_days)
          end
        end
      end
    end
  end
end
