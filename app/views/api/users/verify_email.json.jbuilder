if @user && @user.email_verified
  json.status 200
  json.message "Your email address has been verified successfully."
else
  json.status 404
  if @error_code == :bad_request
    json.status 400
    json.error "Invalid or expired verification token."
  elsif @error_code == :internal_server_error
    json.status 500
    json.error "An unexpected error occurred on the server."
  end
end
json.message "Email verified successfully."
