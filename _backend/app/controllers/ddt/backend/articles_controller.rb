module Ddt
  class Backend::ArticlesController < Backend::BaseController
    check_permission :shop, :wechat_account, :manage
    before_action :set_article, only: [:show, :edit, :update, :destroy]
    before_action :set_material, only: [:new, :create, :edit, :update, :destroy]
    helper Ddt::Backend::ShopsHelper
    helper Ddt::Backend::MaterialsHelper

    def index
      respond_to do |format|
        format.json{
          @q = @current_shop.articles.real.ransack(params[:q])
          @articles = @q.result(distinct: true).limit(20)
          result = @articles.flatten.map do |article|
            article.select_json(params[:version], params[:querys])
          end
          render json: result
        }
        format.html{
          @articles = @current_shop.articles.paginate(page: params[:page],per_page: 10).order(created_at: :desc)
          render :index
        }
      end
    end

    def new
      unless @material.nil?
        if @material.articles.size<8
          @article = @material.articles.build
          @article.shop_id = @current_shop.id
          @article.save(validate: false)
        end
      else
        @article = @current_shop.articles.build
      end
      respond_to do |format|
        format.js {render 'reflesh'}
        format.html {render :new}
      end
    end

    def create
      if @material.nil?
        @article = @current_shop.articles.build(article_params.merge(link_type: Ddt::Article::ARTICLE_SHOW_LINK))
        if @article.save
          redirect_to backend_shop_articles_path(@current_shop)
        end
      else
        @article = @material.articles.build(article_params)
        if @article.save
          @article.set_position(params[:article][:position])
          render 'ddt/backend/materials/edit'
        else
          logger.error "errors are #{@article.errors.to_json}"
          @errors = @article.errors
          render 'ddt/backend/materials/edit'
        end
      end
    end

    def show
    end

    def edit
      respond_to do |format|
        format.js {render 'reflesh'}
        format.html {render}
      end

    end

    def update
      @article.update(article_params)
      redirect_to backend_shop_articles_path(@current_shop)

    end

    def destroy
      if @material.nil?
        @article.destroy
      else
        @article.destroy
        @article = @material.articles.first
      end
      respond_to do |format|
        format.js {render 'reflesh'}
        format.html {redirect_to backend_shop_articles_path(@current_shop)}
      end
    end

    private

    def set_article
      if params[:material_id]
        @article = @current_shop.materials.find(params[:material_id]).articles.find(params[:id])
      else
        @article = @current_shop.articles.find(params[:id])
      end
    end

    def set_material
      @material = @current_shop.materials.find_by_id(params[:material_id])
    end

    def article_params
      params.require(:article).permit(:title, :description, :image, :url, :material_id, :link_type, :position, :introduction)
    end
  end
end
