if @user.errors.any?
  json.error @user.errors.full_messages
else
  json.status 200
  json.message "Profile updated successfully."
end

json.user do
  json.extract! @user, :id, :username, :email, :created_at, :updated_at
end
