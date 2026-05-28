module Ddt
  module Api
    module V1
      module Agentsys
        class BrandsController < BaseController
          before_action :set_brand, only: [:show, :update]

          def index
            brands = current_agent.is_oem? ? Ddt::Brand.where(agent: current_agent) : Ddt::Brand.none
            authorize! brands, to: :index?, with: Ddt::Agentsys::BrandPolicy
            render json: brands.map { |b| brand_json(b) }
          end

          def show
            authorize! @brand, to: :show?
            render json: brand_detail_json(@brand)
          end

          def create
            authorize! Ddt::Brand, to: :create?, with: Ddt::Agentsys::BrandPolicy
            brand = Ddt::Brand.new(brand_params.merge(agent: current_agent))
            if brand.save
              render json: brand_detail_json(brand), status: :created
            else
              render json: { errors: [{ status: 422, title: "创建失败", detail: brand.errors.full_messages.join(", "), code: "VALIDATION_ERROR" }] }, status: :unprocessable_entity
            end
          end

          def update
            authorize! @brand, to: :update?
            if @brand.update(brand_params)
              render json: brand_detail_json(@brand)
            else
              render json: { errors: [{ status: 422, title: "更新失败", detail: @brand.errors.full_messages.join(", "), code: "VALIDATION_ERROR" }] }, status: :unprocessable_entity
            end
          end

          private

          def set_brand
            @brand = Ddt::Brand.where(agent: current_agent).find(params[:id])
          end

          def brand_json(brand)
            {
              id: brand.id,
              name: brand.name,
              domain: brand.domain.to_s,
              merchant_count: brand.shops.count,
              status: brand.active? ? "active" : "inactive",
              updated_at: brand.updated_at.to_s
            }
          end

          def brand_detail_json(brand)
            shops = brand.shops.limit(50).select(:id, :name, :is_give_up, :expiration_time)
            brand_json(brand).merge(
              description: brand.description.to_s,
              config: brand_config(brand),
              merchants: shops.map { |s| { name: s.name, status: s.is_give_up? ? "inactive" : "active", expires_at: s.expiration_time&.to_s } }
            )
          end

          def brand_config(brand)
            {
              primaryColor: brand.primary_color.to_s,
              logoUrl: brand.logo&.url.to_s,
              welcomeText: brand.welcome_text.to_s,
              supportPhone: brand.support_phone.to_s
            }
          end

          def brand_params
            params.permit(:name, :domain, :description, :status, config: {})
          end
        end
      end
    end
  end
end
