Rails.application.routes.draw do
  resources :products
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root to: "products#index"
  get "stripe/connect", to: "stripe#connect", as: :stripe_connect

  scope '/checkout' do
    post 'create', to: 'stripe#create_checkout', as: 'checkout_create'
    get 'cancel', to: 'stripe#cancel_checkout', as: 'checkout_cancel'
    get 'success', to: 'stripe#success_checkout', as: 'checkout_success'
  end

end
