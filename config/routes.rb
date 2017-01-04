Rails.application.routes.draw do

  get "ext/:user_uuid" => "extensions#show"
  get "ext/:user_uuid/import" => "extensions#import"
  post "ext/:user_uuid/push" => "extensions#push"
  get "dropbox_redirect" => "extensions#dropbox_auth_complete"

  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "dropbox#index"
end
