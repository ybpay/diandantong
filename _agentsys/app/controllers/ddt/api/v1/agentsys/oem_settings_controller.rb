module Ddt
  module Api
    module V1
      module Agentsys
        class OemSettingsController < BaseController
          before_action :require_oem_agent

          def show
            authorize! current_agent, to: :show?, with: Ddt::Agentsys::OemSettingPolicy
            agent = current_agent
            render json: {
              system_name: agent.support_brand_name,
              company_name: agent.support_company_name,
              logo_url: agent.logo&.url.to_s,
              favicon_url: agent.rect_logo&.url.to_s,
              colors: oem_colors(agent),
              domain: oem_domains(agent),
              wechat: oem_wechat(agent)
            }
          end

          def update
            authorize! current_agent, to: :update?, with: Ddt::Agentsys::OemSettingPolicy
            agent = current_agent
            attrs = oem_update_params
            if agent.update(attrs)
              render json: { data: { message: "保存成功" } }
            else
              render json: { errors: [{ status: 422, title: "保存失败", detail: agent.errors.full_messages.join(", "), code: "VALIDATION_ERROR" }] }, status: :unprocessable_entity
            end
          end

          private

          def require_oem_agent
            unless current_agent.is_oem?
              render json: { errors: [{ status: 403, title: "仅OEM代理商可访问", code: "FORBIDDEN" }] }, status: :forbidden
            end
          end

          def oem_colors(agent)
            {
              primary: agent.theme_primary_color.presence || "#409eff",
              secondary: agent.theme_secondary_color.presence || "#67c23a",
              accent: agent.theme_accent_color.presence || "#e6a23c"
            }
          end

          def oem_domains(agent)
            {
              primary: agent.domain.to_s,
              h5: agent.h5_domain.to_s,
              pos: agent.pos_domain.to_s
            }
          end

          def oem_wechat(agent)
            wechat = agent.wechat_config
            {
              appId: wechat&.app_id.to_s,
              appSecret: ""
            }
          end

          def oem_update_params
            params.permit(:brand, :domain, :company_name, :logo, :rect_logo)
          end
        end
      end
    end
  end
end
