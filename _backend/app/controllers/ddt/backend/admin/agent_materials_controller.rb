# encoding: utf-8
module Ddt
  class Backend::Admin::AgentMaterialsController < Backend::BaseAdminController
    before_action :set_agent_material, only: [:show, :edit, :update, :destroy]

    # GET /agent_materials
    # GET /agent_materials.json
    def index
      @agent_materials = AgentMaterial.all
    end

    # GET /agent_materials/1
    # GET /agent_materials/1.json
    def show
    end

    # GET /agent_materials/new
    def new
      @agent_material = AgentMaterial.new
    end

    # GET /agent_materials/1/edit
    def edit
    end

    # POST /agent_materials
    # POST /agent_materials.json
    def create
      @agent_material = AgentMaterial.new(agent_material_params)

      respond_to do |format|
        if @agent_material.save
          format.html { redirect_to [:backend, @agent_material], notice: 'Agent material was successfully created.' }
          format.json { render action: 'show', status: :created, location: @agent_material }
        else
          format.html { render action: 'new' }
          format.json { render json: @agent_material.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /agent_materials/1
    # PATCH/PUT /agent_materials/1.json
    def update
      respond_to do |format|
        if @agent_material.update(agent_material_params)
          format.html { redirect_to [:backend, @agent_material], notice: 'Agent material was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @agent_material.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /agent_materials/1
    # DELETE /agent_materials/1.json
    def destroy
      @agent_material.destroy
      respond_to do |format|
        format.html { redirect_to backend_agent_materials_url }
        format.json { head :no_content }
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_agent_material
      @agent_material = AgentMaterial.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def agent_material_params
      params.require(:agent_material).permit(:title, :content, :d_files_attributes => [:id, :file_name, :file_path, :_destroy ])
    end

  end
end
