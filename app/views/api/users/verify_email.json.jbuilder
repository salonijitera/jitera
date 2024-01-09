if @user
  json.status 200
  json.message "Email verified successfully."
else
  json.status 422
  json.error "Verification failed. Invalid or expired verification token."
end
json.message "Email verified successfully."
