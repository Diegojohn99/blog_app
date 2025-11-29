class User < ApplicationRecord
  enum :role, { user: 0, moderator: 1, admin: 2 }
  
  after_initialize :set_default_role, if: :new_record?
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :articles, dependent: :destroy
  
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :role, presence: true
  
  private
  
  def set_default_role
    self.role ||= :user
  end
end
