#encoding: utf-8
module Ddt
  class TableClearWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 0, :queue => :seldom
    def perform(table_id, order_id)
      table = Ddt::Table.using(:master).find(table_id)
      table.clear if table.current_order_id == order_id && table.can_clear?
    end
  end
end
