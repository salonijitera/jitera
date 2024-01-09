class User < ApplicationRecord
  # validations

  # end for validations
  has_many :custom_access_tokens

  class << self
  end
end
