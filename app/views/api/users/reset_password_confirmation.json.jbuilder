json.status @status_code

if @status_code == :ok
  json.message "Password reset successfully."
else
  json.error @error_message
end
