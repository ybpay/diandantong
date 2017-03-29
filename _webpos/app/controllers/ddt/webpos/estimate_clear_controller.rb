module Ddt
  module Webpos
    class EstimateClearController < Webpos::BaseController
      before_action :set_variant, only: [:add, :remove ,:add_reciprocal ,:remove_reciprocal]
      check_permission :branch, :product, :estimate_clear, except: [:index]

      def index
        @variants = @current_branch.variants.estimate_clear_or_reciprocal
        @variants = filter_master(@variants.to_a)
      end

      def add
        if @variant.add_estimate_clear
          render :variant
        else
          render json: { errors: @variant.errors.full_messages }, status: :bad_request
        end
      end

      def remove
        if @variant.remove_estimate_clear
          render :variant
        else
          render json: { errors: @variant.errors.full_messages }, status: :bad_request
        end
      end

      def clear
        Ddt::Variant.remove_estimate_clear_of(@current_branch)
        render json: {ok: true}
      end

      def add_reciprocal
        if @variant.add_estimate_clear_reciprocal(quantity: params[:quantity].to_i)
          render :variant
        else
          render json: { errors: @variant.errors.full_messages }, status: :bad_request
        end
      end

      def remove_reciprocal
        if @variant.remove_estimate_clear_reciprocal
          render :variant
        else
          render json: { errors: @variant.errors.full_messages }, status: :bad_request
        end
      end


      private
      def set_variant
        @variant = @current_branch.variants.find(params[:variant_id])
      end

      def filter_master(variants)
        black_list = []
        variants.each do |variant|
          black_list << variant.product_id if variant.is_master?
        end
        variants.delete_if{|v| black_list.include?(v.product_id) && !v.is_master?}
        variants
      end
    end
  end
end
