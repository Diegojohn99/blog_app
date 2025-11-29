class ArticlesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  load_and_authorize_resource

  def index
    @articles = Article.includes(:user).published.recent
  end

  def show
  end

  def new
  end

  def create
    @article = current_user.articles.new(article_params)
    
    if @article.save
      redirect_to @article, notice: 'Artículo creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: 'Artículo actualizado exitosamente.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_url, notice: 'Artículo eliminado exitosamente.'
  end

  private

  def article_params
    params.require(:article).permit(:title, :content, :image, :image_style)
  end
end
