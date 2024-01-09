
json.status @login_response[:status]
json.message @login_response[:message] if @login_response[:message]
json.access_token @login_response[:access_token]
json.user do
  json.id @login_response[:user][:id]
  json.username @login_response[:user][:username]
  json.email @login_response[:user][:email]
  json.created_at @login_response[:user][:created_at].iso8601(3)
end
