class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def cirro
    @user = create_user

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

  private

  def auth
    request.env["omniauth.auth"]
  end

  def create_user
    User.where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = "#{::Devise.friendly_token[0, 10]}@example.cirro.io"
      user.screenname = auth.info.screenname
      user.password = ::Devise.friendly_token[0, 20]
    end
  end
end
