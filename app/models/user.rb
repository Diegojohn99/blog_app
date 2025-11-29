class User < ApplicationRecord
  enum :role, { user: 0, moderator: 1, admin: 2 }
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :articles, dependent: :destroy
  
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true
end
