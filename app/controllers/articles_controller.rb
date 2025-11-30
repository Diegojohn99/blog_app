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
    
    image_error = nil
    
    # Handle cropped image (base64 data)
    if params[:article][:cropped_image].present?
      image_error = process_cropped_image(@article, params[:article][:cropped_image])
    # Handle image URL
    elsif params[:article][:image_url].present? && !params[:article][:image].present?
      image_error = process_image_url(@article, params[:article][:image_url])
    end
    
    if image_error
      flash.now[:alert] = image_error
      render :new, status: :unprocessable_entity
    elsif @article.save
      redirect_to @article, notice: 'Artículo creado exitosamente.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    image_error = nil
    
    # Handle cropped image (base64 data)
    if params[:article][:cropped_image].present?
      image_error = process_cropped_image(@article, params[:article][:cropped_image])
    # Handle image URL - ONLY if it changed or if we don't have an image yet
    elsif params[:article][:image_url].present? && !params[:article][:image].present?
      # Check if URL changed or if we need to attach a new image
      if params[:article][:image_url] != @article.image_url || !@article.image.attached?
        image_error = process_image_url(@article, params[:article][:image_url])
      end
    end
    
    if image_error
      flash.now[:alert] = image_error
      render :edit, status: :unprocessable_entity
    elsif @article.update(article_params)
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
    return nil unless base64_data.present?
    
    # Extract the base64 data and content type
    if base64_data.match(/^data:image\/(\w+);base64,(.*)/)
      content_type = "image/#{$1}"
      encoded_data = $2
      
      # Decode the base64 data
      decoded_data = Base64.decode64(encoded_data)
      
      # Validate image size (max 10MB)
      if decoded_data.bytesize > 10.megabytes
        return "La imagen es demasiado grande. Por favor, usa una imagen menor a 10MB."
      end
      
      # Create a temporary file
      filename = "cropped_image_#{Time.now.to_i}.#{$1}"
      
      # Attach the image
      article.image.attach(
        io: StringIO.new(decoded_data),
        filename: filename,
        content_type: content_type
      )
      
      return nil # Success
    else
      return "Formato de imagen inválido. Por favor, intenta con otra imagen."
    end
  rescue => e
    Rails.logger.error "Error processing cropped image: #{e.message}"
    return "Error al procesar la imagen. Por favor, intenta con otra imagen o formato diferente."
  end

  def process_image_url(article, url)
    return nil unless url.present?
    
    require 'open-uri'
    
    # Validate URL format
    begin
      uri = URI.parse(url)
      unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        return "URL inválida. Por favor, usa una URL que comience con http:// o https://"
      end
    rescue URI::InvalidURIError
      return "URL inválida. Por favor, verifica la URL e intenta nuevamente."
    end
    
    # Download the image from URL with timeout
    begin
      downloaded_image = URI.open(url, 
        read_timeout: 10,
        redirect: true,
        "User-Agent" => "Mozilla/5.0"
      )
      
      # Validate content type
      content_type = downloaded_image.content_type
      unless content_type&.start_with?('image/')
        return "La URL no apunta a una imagen válida. Por favor, intenta con otra URL."
      end
      
      # Validate file size
      if downloaded_image.size > 10.megabytes
        return "La imagen es demasiado grande. Por favor, usa una imagen menor a 10MB."
      end
      
      # Extract filename from URL or use a default
      filename = File.basename(uri.path)
      filename = "image_#{Time.now.to_i}.jpg" if filename.blank? || !filename.include?('.')
      
      # Attach the image
      article.image.attach(
        io: downloaded_image,
        filename: filename
      )
      
      return nil # Success
    rescue OpenURI::HTTPError => e
      return "No se pudo descargar la imagen. Verifica que la URL sea correcta y accesible."
    rescue Timeout::Error, Net::ReadTimeout
      return "La descarga de la imagen tardó demasiado. Por favor, intenta con otra URL."
    rescue => e
      Rails.logger.error "Error processing image URL: #{e.message}"
      return "Error al cargar la imagen desde la URL. Por favor, intenta con otra imagen."
    end
  end
end
