module Ddt
  class Backend::FormElementsController < Backend::BaseController
    check_permission :branch, :form_element, base_permission_actions.merge({save_sequence: :update, new_select: :create})
    before_action :set_form_element, only: [:show, :edit, :update, :destroy]
    layout 'ddt/layouts/backend/branch'

    def index
      @form_elements = @current_branch.form_elements.order("sequence")
    end

    def show
    end

    def save_sequence
      if params[:sequence].present?
        params[:sequence].split(',').each_with_index do |id, s|
          @current_branch.form_elements.find_by_id_and_shop_id(id, @current_shop.id).update_attribute(:sequence, s)
        end
      end
    end

    def new
      @form_element = FormElementText.new
      render :new
    end

    def new_select
      @form_element = FormElementSelect.new
      3.times { @form_element.form_elements.build }
      respond_to do |format|
        format.js {render :new}
      end
    end

    def edit
    end

    def create
      @form_element = @current_branch.form_elements.build(form_element_params)
      if @form_element.save
        render :reset
      else
        render :new
      end
    end

    def update
      if @form_element.update(form_element_params.except(:support_order_types))
        render :reset
      else
        render :edit
      end
    end

    def destroy
      @form_element.destroy
      render :reset
    end

    private
    def set_form_element
      @form_element = FormElement.find(params[:id])
    end

    def form_element_params
      type = params[:type].demodulize.underscore.to_sym
      hook_data = {branch_id: @current_branch.id, shop_id: @current_shop.id}
      params[type].merge! hook_data
      if params[type][:form_elements_attributes].present?
        params[type][:form_elements_attributes].keys.each do |key|
          params[type][:form_elements_attributes][key].merge! hook_data.merge({type: FormElementOption.name})
        end
      end

      params.require(type).permit(:type, :statement, :need, :placeholder,
       :shop_id, :sequence, :form_element_id, :branch_id, :deleted_at, :support_delivery, :support_eat_in_hall, :support_reservation, :support_fastfood,
       form_elements_attributes: [:id, :need, :placeholder, :form_element_id, :_destroy, :type,
        :statement, :sequence, :shop_id, :branch_id])
    end

  end
end
