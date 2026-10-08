class User < ApplicationRecord
  has_secure_password

  has_many :api_tokens, dependent: :destroy
  has_many :lists, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :time_zone, presence: true
end
