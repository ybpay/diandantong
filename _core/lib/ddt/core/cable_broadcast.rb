module Ddt
  module CableBroadcast
    def broadcast_to_webpos(account_id, message)
      WebposChannel.broadcast_to(
        Ddt::Account.find(account_id),
        message
      )
    end

    def broadcast_to_backend(account_id, message)
      BackendChannel.broadcast_to(
        Ddt::Account.find(account_id),
        message
      )
    end

    def broadcast_to_kitchen(branch_id, message)
      ActionCable.server.broadcast("kitchen:branch:#{branch_id}", message)
    end

    def broadcast_to_tables(branch_id, message)
      ActionCable.server.broadcast("tables:branch:#{branch_id}", message)
    end
  end
end
