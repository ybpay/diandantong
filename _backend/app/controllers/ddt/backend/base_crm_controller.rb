module Ddt
  module Backend
    class BaseCrmController < Backend::BaseController
      respond_to :json
      skip_before_action :verify_authenticity_token
    end
  end
end
