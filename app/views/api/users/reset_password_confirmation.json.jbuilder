json.status @status_code

if @status_code == 200
  json.message "Your password has been reset successfully."
elsif @status_code == 400
  json.error "The request was malformed or had invalid parameters."
elsif @status_code == 404
  json.error "Invalid or expired password reset token."
elsif @status_code == 422
  json.error "Password must be at least 8 characters long."
elsif @status_code == 500
  json.error "An unexpected error occurred on the server."
else
  json.error @error_message
end
