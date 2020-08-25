Rails.application.routes.draw do
  # devise_for :users

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    omniauth_callbacks: 'users/omniauth_callbacks'
  } do
    get 'sign_in', to: 'devise/sessions#new'
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "home#index"
end
