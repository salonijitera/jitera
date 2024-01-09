class UserMailer < ApplicationMailer
  def send_password_reset_instructions(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: I18n.t('devise.mailer.reset_password_instructions.subject')) do |format|
      format.html { render 'user_mailer/reset_password_instructions.html.slim' }
    end
  end
end

end
