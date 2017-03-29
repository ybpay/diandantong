module Ddt
  class Backend::ItemNotesController < Backend::BaseController
    check_permission :branch, :item_note
    before_action :set_item_note, only: [:edit, :destroy, :update]
    layout 'ddt/layouts/backend/branch'

    def index
      @q = @current_branch.item_notes.ransack(params[:q])
      @item_notes = @q.result.distinct
      respond_to do |format|
        format.html
        format.json {
          render json: @item_notes.map(&:select_json)
        }
      end
    end

    def show

    end

    def new
      @item_note = @current_branch.item_notes.build
      respond_to do |format|
        format.js
      end
    end

    def create
      @item_note = @current_branch.item_notes.build(item_note_params)
      respond_to do |format|
        format.js do
          if @item_note.save
            render :create
          else
            render :new
          end
        end
      end
    end

    def edit
      respond_to do |format|
        format.js
      end
    end

    def update
      if @item_note.update(item_note_params)
        @item_note.change_position(params[:position])
        @item_note.touch
        render :update
      else
        render :edit
      end
    end

    def destroy
      @item_note.destroy
      respond_to do |format|
        format.js
      end
    end

    private

    def set_item_note
      @item_note = @current_branch.item_notes.find(params[:id])
    end

    def item_note_params
      params.require(:item_note).permit(:name, :tag_names, :product_ids_string)
    end

  end
end
