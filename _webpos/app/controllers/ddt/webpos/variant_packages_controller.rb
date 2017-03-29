module Ddt
  module Webpos
    class VariantPackagesController < Webpos::BaseController
      before_action :set_variant_package, only: [:update]

      def create
        @variant_package = @current_branch.variant_packages.create(variant_id: params[:variant_id], weight: params[:weight]);
        if @variant_package.errors.blank?
          render :show
        else
          render json: {errors: @variant_package.errors.full_messages}, status: :bad_requrest
        end
      end

      def update
        attrs = {weight: params[:weight]}
        attrs[:variant_id] = params[:variant_id] if params[:variant_id].present?
        if @variant_package.update(attrs)
          render :show
        else
          render json: {errors: @variant_package.errors.full_messages}, status: :bad_request
        end
      end

      private

        def set_variant_package
          @variant_package = @current_branch.variant_packages.find(params[:id])
        end

    end
  end
end
