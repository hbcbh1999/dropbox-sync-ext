Rails.application.routes.draw do

  get "ext/:user_uuid" => "extensions#show"

  post "ext/:user_uuid/push" => "extensions#push"
  post "ext/:user_uuid/initial_sync" => "extensions#initial_sync"
  get "ext/:user_uuid/download" => "extensions#download"

  get "dropbox_redirect" => "extensions#dropbox_auth_complete"

  root to: "dropbox#index"
end
