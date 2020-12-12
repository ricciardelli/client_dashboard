Rails.application.routes.draw do
  root 'companies#index'
  resources :clients
  resources :contractors
  resources :partner_companies
  resources :employees do
    get 'upload' => 'employees#new_upload', as: :new_upload, on: :collection
    post 'upload' => 'employees#upload', as: :upload, on: :collection
  end
  resources :companies
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
