class Article < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  validates :title, presence: true, length: { minimum: 5 }
  validates :content, presence: true
  
  scope :published, -> { where(created_at: ..Time.current) }
  scope :recent, -> { order(created_at: :desc) }
end
