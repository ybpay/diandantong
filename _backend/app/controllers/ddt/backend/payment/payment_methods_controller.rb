module Ddt
  module Backend
    class Payment::PaymentMethodsController < Ddt::Backend::BaseController
      check_permission :shop, :payment_method, { show: :show, [:edit, :update, :switch_version] => :update},
                       only: [:show, :edit, :update, :switch_version]
      include Included::ActsAsModelController
      before_action :set_payment_method, only: [:show, :edit, :update, :destroy]

      def edit
        # 把属性设置为 name 方法指定的名称
        @payment_method.name = @payment_method.name
      end

      def update
        if @payment_method.update(payment_method_params)
          redirect_to [:backend, @current_shop, controller_name], notice: "#{t("activerecord.models.ddt/#{controller_name.singularize}")} 更新成功."
        else
          render :edit
        end
      end

      private
      def set_payment_method
        @payment_method = @model_class.where(shop: @current_shop).first_or_create!
      end

      def payment_method_params
        params.require(@model_name).permit(:shop_id, :type, :name, :description, :active, *@model_class.all_preference_getters)
      end
    end

  end
end
