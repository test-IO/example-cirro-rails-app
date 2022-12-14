class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user

  def edit
    @page_heading = 'My profile'
  end

  def update
    @user.assign_attributes(user_params)
    @user.languages= @user.languages.reject!(&:blank?)
    @user.domains= @user.domains.reject!(&:blank?)
    if @user.save
      redirect_to edit_user_path(@user), notice: 'Profile updated successfully'
    else
      flash[:error] = 'There was an error'
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(languages: [], domains: [])
  end

  def find_user
    @user = current_user
  end
end
