# encoding: utf-8
module Ddt
  class Backend::Admin::LisencesController <  Backend::BaseAdminController
    before_action :set_lisence, only: [:show, :edit, :update, :destroy]

    # GET /lisences
    # GET /lisences.json
    def index
      @lisences = Lisence.all
    end

    # GET /lisences/1
    # GET /lisences/1.json
    def show
    end

    # GET /lisences/1/edit
    def edit
    end

    # PATCH/PUT /lisences/1
    # PATCH/PUT /lisences/1.json
    def update
      respond_to do |format|
        if @lisence.update(lisence_params)
          format.html { redirect_to [:backend, @lisence], notice: 'Lisence was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @lisence.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /lisences/1
    # DELETE /lisences/1.json
    def destroy
      @lisence.destroy
      respond_to do |format|
        format.html { redirect_to backend_lisences_url }
        format.json { head :no_content }
      end
    end

    def feature_modules
      render json: FeatureModuleGroup.select_json
    end


    private
    # Use callbacks to share common setup or constraints between actions.
    def set_lisence
      @lisence = Lisence.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lisence_params
      params.require(:lisence).permit(:lisence_no, :price, :is_used, :increment_days, :lisence_type, :agent_id,:feature_module_group)
    end
  end
end
