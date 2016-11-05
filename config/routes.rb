Rails.application.routes.draw do
  resources :video_files
  root to: 'video_files#index'
end
