module Ddt
  class Weixin::ArticlesController < WeixinApplicationController
    before_action :set_article
    respond_to :json

    def show
      fresh_when(@article)
    end

    private
    def set_article
      @article = Ddt::Article.find(params[:id])
    end

  end
end