class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def cirro
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      @user.update_cirro_access_token(request.env["omniauth.auth"])
      sign_in_and_redirect @user, event: :authentication
    else
      flash[:error] = 'There was an error signing you in!'
      redirect_to root_path
    end
  end

  def failure
    flash[:error] = 'There was an error signing you in!'
    redirect_to root_path
  end
end
