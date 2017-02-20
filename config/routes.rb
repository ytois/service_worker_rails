Rails.application.routes.draw do
  root 'root#index'

  namespace :api do
    post :subscribe, to: 'api#subscribe'
    post :push_message, to: 'api#push_message'
  end
end
