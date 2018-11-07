# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, path: "account", controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: 'users/sessions',
    registrations: 'users/registrations',
  }

  # /admin
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web, at: "/admin/sidekiq"
    mount ExceptionTrack::Engine, at: "/admin/exception-track"
  end

  namespace :admin do
    root to: "dashboards#show"
    resource :dashboard
  end

  # short attachment url
  get "/uploads/:id" => "blobs#show", as: :upload

  resource :account_settings, as: :account_settings, path: "account/settings" do
    collection do
      get :account
    end
  end

  root to: "dashboards#index"
  resource :dashboard do
    member do
      get :activities
      get :groups
      get :repositories
      get :docs
      get :stars
      get :watches
    end
  end
  get "new", to: "repositories#new", as: :new_repository
  resource :autocomplete do
    collection do
      get :users
    end
  end

  resources :groups do
    resources :group_members, as: :members, path: :members
    resource :group_settings, as: :settings, path: :settings
  end
  resources :versions

  # NOTE! Keep :profile routes bottom of routes.rb
  resources :repositories, only: %i(index create)
  resources :users, id: /[#{BookLab::Slug::FORMAT}]*/, path: "", as: "users" do
    member do
      post :follow
      delete :unfollow
    end

    resources :repositories, path: "", as: "repositories", only: %i(show update destroy) do
      member do
        get :docs, path: "docs/list"
        get :toc, path: "toc/edit"
        patch :toc, path: "toc/edit"
        post :action
        delete :action
      end
      resource :repository_settings, path: "settings", as: :settings do
        collection do
          get :show, path: "profile"
          put :update, path: "profile"
          patch :update, path: "profile"
          delete :destroy, path: "profile"
          get :advanced
        end
      end

      resources :docs, only: %i(new create)
      resources :docs, path: "", only: %i(show edit update destroy) do
        member do
          get :raw
          get :versions
          patch :revert
        end
      end
    end
  end
end
