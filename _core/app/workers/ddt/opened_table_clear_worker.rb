#encoding: utf-8
module Ddt
  class OpenedTableClearWorker
    include Sidekiq::Worker
    sidekiq_options :retry => 0, :queue => :seldom
    def perform(table_id)
      table = Ddt::Table.using(:master).find(table_id)
      table.clear if table.is_opened?
    end
  end
end
