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
    
    # Handle cropped image (base64 data)
    if params[:article][:cropped_image].present?
      process_cropped_image(@article, params[:article][:cropped_image])
    # Handle image URL
    elsif params[:article][:image_url].present? && !params[:article][:image].present?
      process_image_url(@article, params[:article][:image_url])
    end
    
    if @article.save
      redirect_to @article, notice: 'Artículo creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    # Handle cropped image (base64 data)
    if params[:article][:cropped_image].present?
      process_cropped_image(@article, params[:article][:cropped_image])
    # Handle image URL
    elsif params[:article][:image_url].present? && !params[:article][:image].present?
      process_image_url(@article, params[:article][:image_url])
    end
    
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
    params.require(:article).permit(:title, :content, :image, :image_style, :image_url)
  end

  def process_cropped_image(article, base64_data)
    return unless base64_data.present?
    
    # Extract the base64 data and content type
    if base64_data.match(/^data:image\/(\w+);base64,(.*)/)
      content_type = "image/#{$1}"
      encoded_data = $2
      
      # Decode the base64 data
      decoded_data = Base64.decode64(encoded_data)
      
      # Create a temporary file
      filename = "cropped_image_#{Time.now.to_i}.#{$1}"
      
      # Attach the image
      article.image.attach(
        io: StringIO.new(decoded_data),
        filename: filename,
        content_type: content_type
      )
    end
  rescue => e
    Rails.logger.error "Error processing cropped image: #{e.message}"
  end

  def process_image_url(article, url)
    return unless url.present?
    
    require 'open-uri'
    
    # Download the image from URL
    downloaded_image = URI.open(url)
    
    # Extract filename from URL or use a default
    filename = File.basename(URI.parse(url).path)
    filename = "image_#{Time.now.to_i}.jpg" if filename.blank?
    
    # Attach the image
    article.image.attach(
      io: downloaded_image,
      filename: filename
    )
  rescue => e
    Rails.logger.error "Error processing image URL: #{e.message}"
  end
end
