class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    authorize! :read, :dashboard
    
    @user_articles = current_user.articles.recent
    @total_articles = Article.count
    @total_users = User.count
    
    if current_user.admin?
      @recent_users = User.order(created_at: :desc).limit(5)
    end
  end
end
