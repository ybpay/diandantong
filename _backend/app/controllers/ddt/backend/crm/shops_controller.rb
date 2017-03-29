module Ddt
  class Backend::Crm::ShopsController < Backend::BaseCrmController

    def show
      @shop = @current_shop
    end
  end
end
