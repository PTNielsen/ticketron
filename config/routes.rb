require 'sidekiq/web'

Rails.application.routes.draw do
  use_doorkeeper

  devise_for :users, controllers: { omniauth_callbacks: :auth }
  devise_scope :user do
    get    '/users/sign_in'  => 'auth#login',  as: :new_user_session
    delete '/users/sign_out' => 'auth#logout', as: :destroy_user_session
  end

  resources :mail, only: [:create]

  post 'home' => 'voice#home'

  root to: 'concerts#index'

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/jobs'
  end

  post "/graphql", to: "graphql#execute"

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"

    scope :dev do
      get 'login/:id' => 'dev#force_login'
    end
  end
end
