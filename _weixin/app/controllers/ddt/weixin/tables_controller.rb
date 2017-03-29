module Ddt
  class Weixin::TablesController < WeixinApplicationController
    respond_to :json
    before_action :set_table, only: [:show, :open]
    def show
    end

    def open
      if @table.is_idle?
        @table.open(params[:guest_num])
      end
      Ddt::OrderItemable::Adapter.new(
        store_type: 'for_merge_order',
        table_id: @table.id
      ).attach(session)
      render json: {ok: true}
    end

    def get_all
      @tables = @branch.tables.where(workflow_state: 'idle')
      render json: @tables.map(&:select_json)
    end

    private
    def set_table
      @table = @branch.tables.find(params[:id])
      fresh_when(@table)
    end
  end
end
