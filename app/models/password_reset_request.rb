class PasswordResetRequest < ApplicationRecord
  belongs_to :user

  enum status: %w[pending verified completed cancelled], _suffix: true

  # validations

  # end for validations

  class << self
  end
end
