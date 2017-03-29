module Ddt
  module CommonApi
    module V1
      class TickAccountsController < V1::BaseController
        def index
          @tick_accounts = @current_branch.tick_accounts.enable
          fresh_when([@tick_accounts])
        end
      end
    end
  end
end
