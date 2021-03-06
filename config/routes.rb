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
  root to: "translation_assignments#index"

  resources :users, only: [:edit, :update]
  resources :translation_assignments, only: [:show, :index] do
    member do
      put :accept
      put :reject
    end
  end
  resources :translation_results, only: [:create, :update]

  scope module: 'admin', path: '/admin', as: 'admin' do
    resources :translation_assignments, only: [:new, :create, :show, :index] do
      put :archive, to: 'translation_assignments#archive'
    end
    resources :translation_results, only: [] do
      member do
        patch :accept
        patch :reject
      end
    end
  end
end
