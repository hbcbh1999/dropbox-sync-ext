Rails.application.routes.draw do

  get "ext/:user_uuid" => "extensions#show"
  post "ext/:user_uuid/push" => "extensions#push"
  get "dropbox_redirect" => "extensions#dropbox_auth_complete"

  root to: "dropbox#index"
end
