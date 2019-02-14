namespace :admin do
  resources :groups do
    member do
      post :restore
    end
  end
  resources :users do
    member do
      post :restore
    end
  end
  resources :repositories do
    member do
      post :restore
    end
  end
  resources :docs do
    member do
      post :restore
    end
  end
  resource :licenses
end