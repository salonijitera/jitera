# typed: true
# frozen_string_literal: true

class ShopPolicy < ApplicationPolicy
  def update?
    # Assuming there is a method `admin?` that checks if the user is an admin
    # This is just an example, the actual permission logic will depend on your application's requirements
    user.admin?
  end
end

