class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def after_sign_in_path_for(resource)
    if resource.languages.blank? && resource.domains.blank?
      edit_user_path(resource)
    else
      root_path
    end
  end
end
