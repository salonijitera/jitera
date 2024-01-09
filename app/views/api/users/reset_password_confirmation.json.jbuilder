json.status @status_code

if @status_code == 200
  json.message "Password reset successfully."
else
  json.error @error_message
end
