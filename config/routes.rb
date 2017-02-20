Rails.application.routes.draw do
  root 'root#index'

  namespace :api do
    post :registration, to: 'api#registration'
    post :push_message, to: 'api#push_message'
  end
end
