
class User < ApplicationRecord
  has_many :password_reset_requests, dependent: :destroy

  # validations
  validates :username, presence: { message: "Username is required." }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP, message: "Invalid email address." }
  validates :password, length: { minimum: 8, message: "Password must be at least 8 characters long." }
  validates :username, uniqueness: { message: "Username or email already in use." }
  validates :email, uniqueness: { message: "Username or email already in use." }

  # end for validations

  class << self
  end
end
