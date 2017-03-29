module Ddt
  class Weixin::ComboPackagesController < WeixinApplicationController
    respond_to :json
    def create
      @combo = @branch.combos.find(params[:combo_id])
      # TODO
    end
  end
end