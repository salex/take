Rails.application.routes.draw do

  resources :assessors do
    member do
      post :post
      get :display
    end
  end
  
  mount Take::Engine => "/take"
  root :to => "assessors#index"
  
end
