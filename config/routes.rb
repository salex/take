Take::Engine.routes.draw do


  resources :assessments do
    member do
      post :post
      get :clone
      get :display
    end
    collection do
      get :group
      get :clone_group
    end
    resources :questions, :only => [ :new, :create] 
  end

  resources :questions, :only => [:show, :edit, :update, :destroy] do
    resources :answers, :only => [ :new, :create] 
    member do
      get :edit_answers
      get :clone
    end
  end
  resources :answers, :only => [:show, :edit, :update, :destroy]

  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'profile', to: 'users#edit', as: 'profile'

  root :to => "take#about"
end
