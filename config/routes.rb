PushWebApp::Application.routes.draw do
  post "/push/v1/log", to: 'logger#create'
  post "/push/v1/pushPackages/web.com.example.app", to: 'push_package#create'
  post "/push/v1/devices/:device_id/registrations/web.com.example.app", to: 'push_package#register'

  root :to => "home#index"
  devise_for :users, :controllers => {:registrations => "registrations"}
  resources :users
end