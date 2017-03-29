module Ddt
  class Backend::EventsController < Backend::BaseController
    check_permission :shop, :wechat_account, :manage
    before_action :set_event, only: [:edit, :update, :destroy]
    layout 'ddt/layouts/backend/events'

    def index
      params[:flag] ||= 'subscribe'
      if params[:flag] == 'subscribe'
        @subscribe_event = @current_shop.events.by_event_type(:subscribe).first
        @unsubscribe_event = @current_shop.events.by_event_type(:unsubscribe).first
      else
        @keyword_events = @current_shop.events.by_event_type(:keyword_autoreply)
        @unmatch_keyword_event = @current_shop.events.by_event_type(:unmatch).first
      end
      render params[:flag]
    end

    def new
      @event = @current_shop.events.build
      @event.event_type = params[:event_type]
      respond_to do |format|
        format.js {}
      end
    end

    def create
      @event = @current_shop.events.build(fix_params(event_params))
      if @event.save
        if(@event.event_type == "keyword_autoreply")
          @keyword_events = @current_shop.events.by_event_type(:keyword_autoreply)
        end
        render 'refresh'
      else
        render 'edit'
      end
    end

    def edit
      respond_to do |format|
        format.js {}
      end
    end

    def update
      if @event.update(fix_params(event_params))
        if(@event.event_type == "keyword_autoreply")
          @keyword_events = @current_shop.events.by_event_type(:keyword_autoreply)
        end
        render 'refresh'
      else
        render 'edit'
      end
    end

    def destroy
      @event.destroy
      respond_to do |format|
        format.js {}
      end
    end

    private

    def set_event
      @event = @current_shop.events.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:reply_type, :event_type, :event_key, :system_keyword,:is_system_keyword, :material_id)
    end

    def fix_params(params)
      if(params[:reply_type]=='system_keyword')
        params[:is_system_keyword] = true
        params[:material_id] = nil
      else
        params[:is_system_keyword] = false
        params[:system_keyword] = nil
      end
      return params
    end

  end
end