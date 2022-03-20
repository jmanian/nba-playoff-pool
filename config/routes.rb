Rails.application.routes.draw do
  devise_for :users

  authenticate :user, lambda { |u| u.admin? } do
    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: redirect(CurrentSeason.path)
  resources :picks, only: %i[index new create]
  get '/:sport/:year', to: 'standings#index'
  get '/:sport/:year/:round', to: 'round#show'
end
