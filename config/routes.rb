Rails.application.routes.draw do

  devise_for :users, controllers:{
    registrations: 'users/registrations',
  }
  devise_scope :user do
    get 'destinations', to: 'users/registrations#new_destination'
    post 'destinations', to: 'users/registrations#create_destination'
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'items#index'
  get 'items/sell'
  get 'items/buy'

  resources :items do
    collection do
      get 'get_category_children', defaults: { format: 'json' }
      get 'get_category_grandchildren', defaults: { format: 'json' }
      get 'sell'
    end
    member do
      get 'buy'
      post 'pay'
      get 'done'
    end
  end

  get 'users/logout'

  resources :creditcard, only: [:new, :show] do
    collection do
      post 'show', to: 'creditcard#show'
      post 'pay', to: 'creditcard#pay'
      post 'delete', to: 'creditcard#delete'
    end
  end  
end
