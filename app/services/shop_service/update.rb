# frozen_string_literal: true

module ShopService
  class Update < BaseService
    attr_reader :shop_id, :name, :address, :user

    def initialize(shop_id, name, address, user)
      @shop_id = shop_id
      @name = name
      @address = address
      @user = user
    end

    def call
      # Check user permissions
      raise 'User does not have permission' unless user.can_update_shop_info?

      # Find the shop
      shop = Shop.find_by(id: shop_id)
      raise 'Shop not found' unless shop

      # Validate the new name and address
      raise 'Invalid name format' unless name.is_a?(String) && !name.empty?
      raise 'Invalid address format' unless address.is_a?(String) && !address.empty?

      # Update the shop information
      shop.update!(name: name, address: address)

      # Return the success message with updated shop information
      { shop_id: shop.id, updated_name: shop.name, updated_address: shop.address }
    rescue => e
      # Handle exceptions and return error message
      { error: e.message }
    end
  end
end
