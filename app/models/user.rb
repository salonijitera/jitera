class User < ApplicationRecord
  has_many :password_reset_requests, dependent: :destroy

  # validations

  # end for validations

  class << self
  end
end
