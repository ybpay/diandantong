module Ddt
  module Webpos
    class TickAccountsController < Webpos::BaseController
      def index
        @tick_accounts = @current_branch.tick_accounts.enable
        fresh_when([@tick_accounts])
      end
    end
  end
end
